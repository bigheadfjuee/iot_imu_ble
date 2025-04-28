import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

import 'pages/pose_page.dart';
import 'pages/camera_page.dart';
import 'pages/monitor_page.dart';
import 'pages/upload_page.dart';
import 'pages/setting_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IoT Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'IoT - BLE IMU'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 5,
        child: Scaffold(
          appBar: AppBar(
            bottom: const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.accessibility)),
                Tab(icon: Icon(Icons.camera_alt)),
                Tab(icon: Icon(Icons.upload_file)),
                Tab(icon: Icon(Icons.monitor_heart)),
                Tab(icon: Icon(Icons.settings)),
              ],
            ),
            title: Text(widget.title),
          ),
          body: TabBarView(
            children: [
              PosePage(),
              CameraPage(),
              UploadPage(),
              MonitorPage(),
              SettingPage(),
            ],
          ),
        ),
      ),
    );
  }
}
