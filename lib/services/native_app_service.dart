import 'package:flutter/services.dart';
import '../models/installed_app.dart';

class NativeAppService {
  static const MethodChannel _channel = MethodChannel('app_cloner_bd/apps');

  Future<List<InstalledApp>> getLaunchableApps() async {
    final result = await _channel.invokeMethod<List<dynamic>>('getLaunchableApps');
    if (result == null) return const [];
    return result.map((item) {
      if (item is! Map) {
        throw const FormatException('Unexpected app item returned by Android.');
      }
      return InstalledApp.fromMap(item);
    }).toList(growable: false);
  }

  Future<String> getCloneCapabilityMessage() async {
    return await _channel.invokeMethod<String>('getCloneCapability') ??
        'Clone capability information is unavailable.';
  }
}
