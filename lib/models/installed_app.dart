class InstalledApp {
  const InstalledApp({
    required this.packageName,
    required this.label,
  });

  final String packageName;
  final String label;

  factory InstalledApp.fromMap(Map<Object?, Object?> map) {
    final packageName = map['packageName'];
    final label = map['label'];
    if (packageName is! String || label is! String) {
      throw const FormatException('Invalid installed-app response from Android.');
    }
    return InstalledApp(packageName: packageName, label: label);
  }
}
