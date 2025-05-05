import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iot_imu_ble/model/imu_data.dart';

final ImuDataProvider = Provider((_) => ImuData());
