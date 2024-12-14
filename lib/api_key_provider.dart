import 'dart:io';
import 'package:http/http.dart' as http;

class ApiKeyProvider {
  static Future<String> getApiKey() async {
    final ipAddress = await _getCurrentIpAddress();

    if (Platform.isAndroid) {
      if (ipAddress == "147.235.218.171") {
        // Example emulator IP
        return 'AIzaSyBzgx3RCLweT1lHvMaT3lU8Xo8oroNqFhI';
      } else {
        return 'AIzaSyD5pFNUR9YZY-Kr7PqKzmD_SbdIz-FJ_sQ';
      }
    } else if (Platform.isIOS) {
      return 'AIzaSyD66RdQ4IcfomKkS9BIxok23AFZRqLTkAk';
    } else {
      throw UnsupportedError("Unsupported platform");
    }
  }

  static Future<String> _getCurrentIpAddress() async {
    try {
      final response =
          await http.get(Uri.parse('https://api.ipify.org?format=json'));
      if (response.statusCode == 200) {
        final ip = response.body.split('"')[3]; // Extract IP from JSON
        return ip;
      } else {
        return "UNKNOWN";
      }
    } catch (e) {
      return "UNKNOWN";
    }
  }
}
