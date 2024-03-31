import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class Home extends StatefulWidget {
  final List<File> imageFiles;
  final List<File> videoFiles;
  const Home({super.key, required this.imageFiles, required this.videoFiles});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late List<Future<Uint8List?>> _thumbnailFutures;

  @override
  void initState() {
    super.initState();
    _thumbnailFutures =
        widget.videoFiles.map((file) => _generateThumbnail(file)).toList();
    _tabController =
        TabController(length: 2, vsync: this); // Define the number of tabs
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Status Saver'),
        bottom: TabBar(
          tabAlignment: TabAlignment.fill,
          labelColor: Colors.black,
          indicatorColor: Colors.black,
          controller: _tabController,
          tabs: const [
            Tab(
              text: 'Photos',
            ),
            Tab(
              text: 'Videos',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 0,
              mainAxisSpacing: 0,
            ),
            itemCount: widget.imageFiles.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () async {
                  await savePhoto(widget.imageFiles[index], context);
                },
                child: Container(
                  padding: const EdgeInsets.all(4.0),
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(widget.imageFiles[index],
                          fit: BoxFit.cover)),
                ),
              );
            },
          ),
          GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 0,
              mainAxisSpacing: 0,
            ),
            itemCount: widget.videoFiles.length,
            itemBuilder: (context, index) {
              return FutureBuilder(
                future: _thumbnailFutures[index],
                builder: (context, AsyncSnapshot<Uint8List?> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return const Center(
                      child: Text('Error loading thumbnail'),
                    );
                  } else {
                    return GestureDetector(
                      onTap: () async {
                        await saveVideo(widget.videoFiles[index]);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: snapshot.data != null
                              ? Image.memory(
                                  snapshot.data!,
                                  fit: BoxFit.fill,
                                )
                              : Container(), // Placeholder if thumbnail is not available,
                        ),
                      ),
                    );
                  }
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> savePhoto(File file, BuildContext context) async {
    // Save the image to the device's media storage
    await ImageGallerySaver.saveFile(file.path);

    // Show a snackbar message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('File saved successfully'),
      ),
    );
  }

  Future<void> saveVideo(File file) async {
    // Save the image to the device's media storage
    await ImageGallerySaver.saveFile(file.path);

    // Show a snackbar message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('File saved successfully'),
      ),
    );
  }

  Future<Uint8List?> _generateThumbnail(File file) async {
    return VideoThumbnail.thumbnailData(
      video: file.path,
      imageFormat: ImageFormat.JPEG,
      maxWidth: 200,
      quality: 25,
    );
  }
}
