import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../src/proxy_ffi.dart';

// 使用 Riverpod 來管理 IMU 數據的狀態
// https://riverpod.dev/docs/introduction/getting_started

class ImuData {
  Uint32 timestamp = 1 as Uint32;
  Float aX = 0.1 as Float;
  Float aY = 0.2 as Float;
  Float aZ = 0.3 as Float;
  Float gX = -0.1 as Float;
  Float gY = -0.2 as Float;
  Float gZ = -0.3 as Float;
}
