import 'package:flutter_jailbreak_detection/flutter_jailbreak_detection.dart';

class JailbreakDetection {
  static Future<bool> isJailbroken() async {
    return await FlutterJailbreakDetection.jailbroken;
  }
}
