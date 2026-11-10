import 'package:flutter_test/flutter_test.dart';
import 'package:app_cloner_bd/models/installed_app.dart';

void main() {
  test('InstalledApp parses the native scanner response', () {
    final app = InstalledApp.fromMap({
      'packageName': 'com.example.test',
      'label': 'Example',
    });

    expect(app.packageName, 'com.example.test');
    expect(app.label, 'Example');
  });

  test('InstalledApp rejects malformed native responses', () {
    expect(
      () => InstalledApp.fromMap({'packageName': 123, 'label': 'Example'}),
      throwsFormatException,
    );
  });
}
