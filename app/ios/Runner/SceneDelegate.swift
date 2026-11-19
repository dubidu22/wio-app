import Flutter
import UIKit

/// Shows the app's one engine (D-373). An engine already started by a
/// background task is shown as it is; its run goes on.
class SceneDelegate: FlutterSceneDelegate {
  override func scene(
    _ scene: UIScene, willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    if let windowScene = scene as? UIWindowScene,
      let app = UIApplication.shared.delegate as? AppDelegate
    {
      app.startEngine(inBackground: false)
      let window = UIWindow(windowScene: windowScene)
      window.rootViewController = FlutterViewController(
        engine: app.engine, nibName: nil, bundle: nil)
      self.window = window
      window.makeKeyAndVisible()
    }
    super.scene(scene, willConnectTo: session, options: connectionOptions)
  }
}
