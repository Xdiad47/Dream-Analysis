import 'package:uuid/uuid.dart';
import 'package:hive/hive.dart';
import '../constants/app_constants.dart';

class DeviceIdGenerator {
  static const _uuid = Uuid();

  // Get or generate device ID
  static String getDeviceId() {
    final box = Hive.box(AppConstants.themeKey);
    String? deviceId = box.get(AppConstants.deviceIdKey);

    if (deviceId == null) {
      deviceId = _uuid.v4();
      box.put(AppConstants.deviceIdKey, deviceId);
    }

    return deviceId;
  }
}
