import UIKit

@UIApplicationMain
final class AppDelegate: NSObject, UIApplicationDelegate {
    var window: UIWindow?

    func applicationDidFinishLaunching(_ application: UIApplication) {
        let window = UIWindow()
        self.window = window

        let root = UIViewController()
        root.view.backgroundColor = .red
        window.rootViewController = root
        window.makeKeyAndVisible()
    }
}
