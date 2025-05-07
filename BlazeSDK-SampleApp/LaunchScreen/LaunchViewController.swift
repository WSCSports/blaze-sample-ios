//
//  LaunchViewController.swift
//  BlazeSDK-SampleApp
//
//  Created by Dor Zafrir on 19/07/2023.
//

import UIKit
import GoogleMobileAds

class LaunchViewController: UIViewController {
    
    struct Constants {
        static let appMainScreenName = "Main"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        initializeAds()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupInitalAppScreen()
    }
    
    private func initializeAds() {
        MobileAds.shared.start()
    }
    
    private func setupInitalAppScreen() {
        setupBlazeSDK()
        goToApp()
    }
    
    private func setupBlazeSDK() {
        BlazeSDKInteractor.shared.initBlazeSDK()
    }
    
    private func goToApp() {
        let storyboard = UIStoryboard(name: Constants.appMainScreenName, bundle: nil)
        guard let vc = storyboard.instantiateInitialViewController() as? TabBarViewController else { return }
        if let scene = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
            scene.updateRootVc(to: vc)
        }
    }

}

