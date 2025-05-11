import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:tflite_flutter/tflite_flutter.dart' as tfl;
import 'ble_data_manager.dart';
import 'line_page.dart';

class BleDataReceiverPage extends StatefulWidget {
  const BleDataReceiverPage({super.key});
  @override
  State<BleDataReceiverPage> createState() => _BleDataReceiverPageState();
}

class _BleDataReceiverPageState extends State<BleDataReceiverPage> {
  final ScrollController _scrollController = ScrollController();
  late bool _uploadEnabled;
  DateTime? _lastUIUpdate;
  int? _previousLogLength;

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
  }

  @override
  void dispose() {
    BleDataManager.instance.removeListener(_refreshUI);
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

    /*
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        setState(() {});
        if (_uploadEnabled) {
          _scrollToBottom();
        }
      });
    }
    */
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }

  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }
  }

  void _toggleUpload(bool value) {
    setState(() {
      _uploadEnabled = value;
      BleDataManager.instance.setUploadEnabled(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final logs = BleDataManager.instance.logMessages;
    final isConnected = BleDataManager.instance.isDeviceConnected;
    final battery = BleDataManager.instance.latestBattery;
    final batteryPercent = BleDataManager.instance.batteryPercent;

    return Scaffold(
      appBar: AppBar(
        title: const Text("IMU資料接收"),
        actions: [
          Row(
            children: [
              Icon(
                _uploadEnabled ? Icons.cloud_upload : Icons.cloud_off,
                color: _uploadEnabled ? Colors.green : Colors.red,
              ),
              Switch(value: _uploadEnabled, onChanged: _toggleUpload),
            ],
          ),
        ],
      ),
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

          if (!_uploadEnabled)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                "⚠️ 資料僅接收，未上傳至資料庫",
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

          // ❌ 藍牙斷線提示
          if (!isConnected)
            const Padding(
              padding: EdgeInsets.only(left: 16.0, bottom: 8),
              child: Text(
                "❌ 裝置已斷線，停止接收資料",
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

          Expanded(
            child: Scrollbar(
              controller: _scrollController,
              thumbVisibility: true,
              thickness: 12,
              radius: const Radius.circular(8),
              child: ListView.builder(
                controller: _scrollController,
                itemCount: logs.length,
                itemBuilder: (context, index) {
                  final log = logs[index];
                  final isSuccess = log.startsWith("✅");
                  final isError = log.startsWith("❌");

                  return ListTile(
                    title: Text(
                      log,
                      style: TextStyle(
                        fontSize: 14,
                        color:
                            isSuccess
                                ? Colors.green
                                : isError
                                ? Colors.red
                                : Colors.black,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          // ✅ 可選的「到最上／下」按鈕區塊
          /*
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _scrollToTop,
                  icon: const Icon(Icons.arrow_upward),
                  label: const Text("到最上面"),
                ),
                ElevatedButton.icon(
                  onPressed: _scrollToBottom,
                  icon: const Icon(Icons.arrow_downward),
                  label: const Text("到最下面"),
                ),
              ],
            ),
          ),
          */
          LinePage(),
        ],
      ),
    );
  }

  /*
  Future<void> PredictPos() async {
    final interpreter = await tfl.Interpreter.fromAsset('gesture_model.tflite');

const double accelerationThreshold = 2.5; // threshold of significant in G's
const int numSamples = 119;
const int tensorArenaSize = 8 * 1024;
UnsignedChar tensorArena[tensorArenaSize] __attribute__((aligned(16)));
const String GESTURES[] = {
  "punch",
  "flex"
};
const int NUM_GESTURES = (sizeof(GESTURES) / sizeof(GESTURES[0]));

// For ex: if input tensor shape [1,5] and type is float32
      // normalize the IMU data between 0 to 1 and store in the model's
      // input tensor
      tflInputTensor->data.f[samplesRead * 6 + 0] = (aX + 4.0) / 8.0;
      tflInputTensor->data.f[samplesRead * 6 + 1] = (aY + 4.0) / 8.0;
      tflInputTensor->data.f[samplesRead * 6 + 2] = (aZ + 4.0) / 8.0;
      tflInputTensor->data.f[samplesRead * 6 + 3] = (gX + 2000.0) / 4000.0;
      tflInputTensor->data.f[samplesRead * 6 + 4] = (gY + 2000.0) / 4000.0;
      tflInputTensor->data.f[samplesRead * 6 + 5] = (gZ + 2000.0) / 4000.0;

var input = [[1.23, 6.54, 7.81. 3.21, 2.22]];

        for (int i = 0; i < NUM_GESTURES; i++) {
          Serial.print(GESTURES[i]);
          Serial.print(": ");
          Serial.println(tflOutputTensor->data.f[i], 6);
        }

var input0 = [1.23];  
var input1 = [2.43];  

// input: List<Object>
var inputs = [input0, input1, input0, input1];  

var output0 = List<double>.filled(1, 0);  
var output1 = List<double>.filled(1, 0);

// output: Map<int, Object>
var outputs = {0: output0, 1: output1};

// inference  
interpreter.runForMultipleInputs(inputs, outputs);

// print outputs
print(outputs)
  }

  */
}
