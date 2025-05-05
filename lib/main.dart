import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'pages/pose_page.dart';
import 'pages/monitor_page.dart';
import 'pages/setting_page.dart';
import 'pages/ble_scan_page.dart';

import 'components/firebase_options.dart';
import 'components/global_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb && Platform.isAndroid) {
    await _requestPermissions(); // 執行時權限請求
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  // runApp(const MyApp());

  runApp(
    /// Providers are above [MyApp] instead of inside it, so that tests
    /// can use [MyApp] while mocking the providers
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => ImuDataProvider())],
      child: const MyApp(),
    ),
  );
}

Future<void> _requestPermissions() async {
  await [
    Permission.bluetooth,
    Permission.bluetoothScan,
    Permission.bluetoothConnect,
    Permission.location, // 有些手機仍需開啟定位才能掃描BLE
  ].request();
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
      home: const MyHomePage(title: 'Smart Racket'),
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
        length: 4,
        child: Scaffold(
          appBar: AppBar(
            bottom: const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.accessibility)),
                Tab(icon: Icon(Icons.bluetooth)),
                Tab(icon: Icon(Icons.monitor_heart)),
                Tab(icon: Icon(Icons.settings)),
              ],
            ),
            title: Text(widget.title),
          ),
          body: TabBarView(
            children: [PosePage(), BleScanPage(), MonitorPage(), SettingPage()],
          ),
        ),
      ),
    );
  }
}
