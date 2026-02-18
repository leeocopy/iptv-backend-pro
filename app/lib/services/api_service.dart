import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:device_info_plus/device_info_plus.dart';

class ApiService {
  static const String baseUrl = 'https://iptv-backend-pro.vercel.app/api';

  Future<String?> getDeviceId() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      return androidInfo.id; // Unique Android ID
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      return iosInfo.identifierForVendor;
    }
    return 'unknown_device';
  }

  Future<Map<String, dynamic>> checkStatus() async {
    try {
      String? deviceId = await getDeviceId();
      if (deviceId == null) throw Exception('Could not get device ID');

      final response = await http.get(
        Uri.parse('$baseUrl/check-status?deviceId=$deviceId'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to check status: ${response.statusCode}');
      }
    } catch (e) {
      return {
        'status': 'error',
        'message': e.toString(),
      };
    }
  }
}
