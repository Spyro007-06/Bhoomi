import 'app_mode.dart';

/// Configuration for deterministic, offline demo behaviour.
///
/// This class only describes demo data and simulation knobs. Repository
/// selection belongs to [AppModeConfig], keeping mode checks out of widgets.
class DemoConfig {
  static bool get isDemoMode => AppModeConfig.isDemo;

  /// Development-only OTP accepted by the local demo authentication flow.
  static const String demoOtp = '123456';

  /// Legacy alias retained for callers that used the previous setting.
  static const String demoCode = demoOtp;

  /// A short wait makes asynchronous demo operations feel realistic.
  static const int latencyMs = int.fromEnvironment(
    'DEMO_LATENCY_MS',
    defaultValue: 450,
  );

  /// Optional testing hook: `login`, `diagnosis`, `alerts`, or `empty_alerts`.
  static const String simulatedFailure = String.fromEnvironment(
    'DEMO_FAILURE',
    defaultValue: '',
  );

  static bool shouldSimulate(String operation) =>
      simulatedFailure.trim().toLowerCase() == operation.toLowerCase();

  // Demo Farmer Identity
  static const String demoFarmerId = 'u_arun_01';
  static const String demoFarmerName = 'Arun Kumar';
  static const String demoPhone = '+919876543210';
  static const String demoRole = 'farmer';

  // Demo Farm Profile
  static const String demoFarmId = 'f_green_valley';
  static const String demoFarmName = 'Green Valley Farm';
  static const String demoLocation = 'Tamil Nadu';
  static const String demoCrop = 'tomato';
  static const String demoVariety = 'Arka Rakshak';
  static const String demoGrowthStage = 'flowering';
  static const double demoLatitude = 11.1271;
  static const double demoLongitude = 78.6569;
}
