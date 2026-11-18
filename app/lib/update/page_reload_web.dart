import 'package:web/web.dart' as web;

/// Loads the web app again, which fetches the new build (D-153).
bool reloadPage() {
  web.window.location.reload();
  return true;
}
