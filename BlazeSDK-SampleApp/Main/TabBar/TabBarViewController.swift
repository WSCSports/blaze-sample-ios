//
//  TabBarViewController.swift
//  BlazeSDK-SampleApp
//
//  Created by Dor Zafrir on 19/07/2023.
//

import UIKit

class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
    }
    
    private func setupTabBar() {
        self.delegate = self
        updateTabBarAppearance(isBlackBg: false)
    }
    
    private func updateTabBarAppearance(isBlackBg: Bool) {
        if #available(iOS 15.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = isBlackBg ? .black : .white
            appearance.stackedLayoutAppearance.selected.iconColor = isBlackBg ? .white : .black
            appearance.stackedLayoutAppearance.normal.iconColor = .gray
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: isBlackBg ? UIColor.white : UIColor.black]
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.gray]
            
            tabBar.standardAppearance = appearance
            tabBar.scrollEdgeAppearance = appearance
        } else {
            tabBar.barTintColor = isBlackBg ? .black : .white
            tabBar.tintColor = isBlackBg ? .white : .black
            tabBar.unselectedItemTintColor = .gray
            tabBar.isTranslucent = false
        }
    }
    
}

extension TabBarViewController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        
        if let index = viewControllers?.firstIndex(of: viewController), let selectedTabBarItem = tabBarController.tabBar.items?[index] {
            switch selectedTabBarItem.title {
            case "Moments Container":
                updateTabBarAppearance(isBlackBg: true)
            default:
                updateTabBarAppearance(isBlackBg: false)
            }
        }
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if viewController == moreNavigationController, let topVC = moreNavigationController.topViewController {
            if moreNavigationController.viewControllers.contains(topVC) {
                moreNavigationController.popViewController(animated: true)
            }
        }
        return true
    }
    
    
}
