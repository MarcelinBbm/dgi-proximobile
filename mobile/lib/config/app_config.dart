enum AppMode { demo, api }

class AppConfig {
  const AppConfig.demo() : mode = AppMode.demo, apiBaseUri = null;
  const AppConfig._(this.mode, this.apiBaseUri);

  final AppMode mode;
  final Uri? apiBaseUri;

  static const demoEmail = 'alex.demo@example.cd';
  static const demoName = 'Alex M.';
  static const defaultMode = String.fromEnvironment('APP_MODE', defaultValue: 'demo');
  static const defaultApiBaseUrl = String.fromEnvironment('API_BASE_URL');

  factory AppConfig.fromEnvironment() => AppConfig.parse(
        mode: defaultMode,
        apiBaseUrl: defaultApiBaseUrl,
      );

  factory AppConfig.parse({required String mode, String apiBaseUrl = ''}) {
    if (mode == 'demo') return const AppConfig.demo();
    if (mode != 'api') throw const FormatException('Unknown application mode');
    final uri = Uri.tryParse(apiBaseUrl.trim());
    if (uri == null ||
        uri.scheme != 'https' ||
        uri.host.isEmpty ||
        uri.userInfo.isNotEmpty ||
        uri.hasQuery ||
        uri.hasFragment ||
        (uri.hasPort && uri.port != 443)) {
      throw const FormatException('An HTTPS API base URL is required');
    }
    final normalized = uri.path.endsWith('/')
        ? uri
        : uri.replace(path: '${uri.path}/');
    return AppConfig._(AppMode.api, normalized);
  }
}
