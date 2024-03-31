import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:statussaver/home.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  List<File> imageFiles = [];
  List<File> videoFiles = [];

  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  Future<void> _getStatuses() async {
    List<File> images = [];
    List<File> videos = [];
    try {
      String statusDirPath =
          '/storage/emulated/0/Android/media/com.whatsapp/WhatsApp/Media/.Statuses/';
      String statusDirPath2 = '/storage/emulated/0/WhatsApp/Media/.Statuses/';

      Directory statusDir = Directory(statusDirPath);
      if (!await statusDir.exists()) {
        statusDir = Directory(statusDirPath2);
      }
      // if (!await statusDir.exists()) {
      //   ScaffoldMessenger.of(context).clearSnackBars();
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(
      //       content: Text('Directory Not Found'),
      //     ),
      //   );
      // }
      // Get list of status files
      List<FileSystemEntity> statusFiles = Directory(statusDir.path).listSync();

      // Check file type and add to corresponding lists
      for (FileSystemEntity file in statusFiles) {
        if (file is File) {
          if (_isImage(file.path)) {
            images.add(file);
          } else if (_isVideo(file.path)) {
            videos.add(file);
          }
        }
      }
    } catch (e) {
      //ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
    setState(() {
      imageFiles = images;
      videoFiles = videos;
    });
  }

  bool _isImage(String path) {
    String extension = path.split('.').last.toLowerCase();
    return extension == 'jpg' || extension == 'jpeg' || extension == 'png';
  }

  bool _isVideo(String path) {
    String extension = path.split('.').last.toLowerCase();
    return extension == 'mp4' || extension == 'avi' || extension == 'mov';
  }

  Future<void> _checkPermissions() async {
    AndroidDeviceInfo build = await DeviceInfoPlugin().androidInfo;
    if (build.version.sdkInt >= 30) {
      var permission = await Permission.manageExternalStorage.request();
      if (permission.isGranted) {
        await _getStatuses();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Manage External Storage not granted'),
          ),
        );
      }
    } else {
      var permission = await Permission.storage.request();
      if (permission.isGranted) {
        await _getStatuses();
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Storage not granted')));
      }
    }
  }

  void _navigateToHome() async {
    // Wait for asynchronous operations to complete
    await Future.wait([_checkPermissions()] as Iterable<Future>).then((_) {
      // After both operations are completed, navigate to Home
      Future.delayed(const Duration(seconds: 1), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Home(
              imageFiles: imageFiles,
              videoFiles: videoFiles,
            ),
          ),
        );
      });
    }).catchError((error) {
      // Handle errors if any
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
          child: Text(
        'Splash Page',
        style: TextStyle(
          fontSize: 18,
        ),
      )),
    );
  }
}
