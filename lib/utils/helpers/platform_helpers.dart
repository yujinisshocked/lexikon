import 'dart:io';
import 'package:flutter_device_type/flutter_device_type.dart';

class PlatformHelpers {
  bool isDesktop() {
    return (Platform.isWindows || Platform.isLinux || Platform.isMacOS || Device.get().isTablet);
  }

  bool isMobile() {
    return (Platform.isAndroid || Platform.isIOS);
  }
}