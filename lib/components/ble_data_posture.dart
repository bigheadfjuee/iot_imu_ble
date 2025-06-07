import 'package:flutter/material.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'line_page.dart';
import 'ble_data_manager.dart';

class BleDataPosturePage extends StatefulWidget {
  const BleDataPosturePage({super.key});
  @override
  State<BleDataPosturePage> createState() => _BleDataPosturePageState();
}

class _BleDataPosturePageState extends State<BleDataPosturePage> {
  final ScrollController _scrollController = ScrollController();
  late bool _uploadEnabled;
  DateTime? _lastUIUpdate;
  int? _previousLogLength;

  late Interpreter interpreter;
  Future<void> loadModel() async {
    interpreter = await Interpreter.fromAsset('assets/badminton_model.tflite');
  }

  @override
  void initState() {
    super.initState();
    if (BleDataManager.instance.hasConnectedOnce &&
        !BleDataManager.instance.uploadEnabled) {
      _uploadEnabled = false;
      BleDataManager.instance.setUploadEnabled(false);
    } else {
      _uploadEnabled = BleDataManager.instance.uploadEnabled;
    }

    BleDataManager.instance.addListener(_refreshUI);
    BleDataManager.instance.setBuildContext(context);
    loadModel();
  }

  Future<void> classifyPosture() async {
    // 準備輸入數據
    // var input = [/* 將圖像數據轉換為模型所需的格式 */];
    // var output = List.filled(1, 0).reshape([1][1]);

    // 執行推理
    // interpreter.run(input, output);

    // 處理輸出
    // print(output);

    /*
    Input details: [
    {'name': 'serving_default_keras_tensor: 0', 'index': 0, 'shape': array([
            1,
            40,
            6,
            1
        ], dtype=int32), 'shape_signature': array([
            -1,
            40,
            6,
            1
        ], dtype=int32), 'dtype': <class 'numpy.float32'>, 'quantization': (0.0,
        0), 'quantization_parameters': {'scales': array([], dtype=float32), 'zero_points': array([], dtype=int32), 'quantized_dimension': 0
        }, 'sparsity_parameters': {}
    }
]

Output details: [
    {'name': 'StatefulPartitionedCall_1: 0', 'index': 19, 'shape': array([
            1,
            3
        ], dtype=int32), 'shape_signature': array([
            -1,
            3
        ], dtype=int32), 'dtype': <class 'numpy.float32'>, 'quantization': (0.0,
        0), 'quantization_parameters': {'scales': array([], dtype=float32), 'zero_points': array([], dtype=int32), 'quantized_dimension': 0
        }, 'sparsity_parameters': {}
    }
]
    */
  }

  @override
  void dispose() {
    BleDataManager.instance.removeListener(_refreshUI);
    interpreter.close();
    super.dispose();
  }

  void _refreshUI() {
    if (!mounted) return;

    final logs = BleDataManager.instance.logMessages;
    final now = DateTime.now();
    if (_lastUIUpdate != null &&
        now.difference(_lastUIUpdate!) < const Duration(milliseconds: 100)) {
      return; // 限制 UI 更新頻率為 100ms 一次
    }

    _lastUIUpdate = now;

    setState(() {});

    final prevLength = _previousLogLength ?? 0;
    _previousLogLength = logs.length;

    if (_uploadEnabled && logs.length > prevLength) {
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }

  @override
  Widget build(BuildContext context) {
    final logs = BleDataManager.instance.logMessages;
    final isConnected = BleDataManager.instance.isDeviceConnected;
    final battery = BleDataManager.instance.latestBattery;
    final batteryPercent = BleDataManager.instance.batteryPercent;

    return Scaffold(
      appBar: AppBar(title: const Text("姿勢判斷"), actions: [Row(children: [
            ],
          )]),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (battery != null && batteryPercent != null)
            Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 8),
              child: Text(
                "🔋 $batteryPercent%（${battery.toStringAsFixed(2)}V）",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

          // ❌ 藍牙斷線提示
          if (!isConnected)
            const Padding(
              padding: EdgeInsets.only(left: 16.0, bottom: 8),
              child: Text(
                "❌ 裝置已斷線，請重新連線",
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

          Center(
            child: Text(
              "Other",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey,
                fontSize: 50,
              ),
            ),
          ),

          LinePage(),
        ],
      ),
    );
  }
}
