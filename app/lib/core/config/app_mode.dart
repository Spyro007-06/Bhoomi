/// The data source selected for a Bhoomi build.
///
/// Demo is deliberately the default so an APK made without build arguments is
/// presentation-ready. Production keeps the existing API-backed repository
/// implementations and can be selected with `--dart-define=DEMO_MODE=false`.
enum AppMode {
  demo,
  production,
}

abstract final class AppModeConfig {
  static const bool _demoEnabled = bool.fromEnvironment(
    'DEMO_MODE',
    defaultValue: true,
  );

  static const AppMode mode = _demoEnabled ? AppMode.demo : AppMode.production;

  static bool get isDemo => mode == AppMode.demo;
  static bool get isProduction => mode == AppMode.production;
}
