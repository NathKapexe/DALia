/// Base URL of the inference API.
///
/// Override it when running the app:
///   flutter run --dart-define=DALIA_API_URL=http://192.168.1.50:8000
///
/// The default is the address an Android emulator uses to reach the computer
/// it runs on.
const String kApiBaseUrl = String.fromEnvironment(
  'DALIA_API_URL',
  defaultValue: 'http://10.0.2.2:8000',
);
