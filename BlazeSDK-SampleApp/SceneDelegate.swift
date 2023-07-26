//
//  SceneDelegate.swift
//  BlazeSDK-SampleApp
//
//  Created by Dor Zafrir on 19/07/2023.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
        
    private lazy var rootVC: UIViewController = appViewController()


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: scene)
        configureWindow()
    }
    
    func updateRootVc(to vc: UIViewController) {
        rootVC = vc
        configureWindow()
    }
    
    private func configureWindow() {
        window?.rootViewController = rootVC
        window?.makeKeyAndVisible()
    }
    
    private func appViewController() -> UIViewController {
        let appViewController = LaunchViewController()
        return appViewController
    }

    func sceneDidDisconnect(_ scene: UIScene) {}
    func sceneDidBecomeActive(_ scene: UIScene) {}
    func sceneWillResignActive(_ scene: UIScene) {}
    func sceneWillEnterForeground(_ scene: UIScene) {}
    func sceneDidEnterBackground(_ scene: UIScene) {}


}

