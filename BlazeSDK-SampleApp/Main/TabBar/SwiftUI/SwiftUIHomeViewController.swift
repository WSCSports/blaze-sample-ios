//
//  SwiftUIHomeViewController.swift
//  BlazeSDK-SampleApp
//
//  Created by Dor Zafrir on 24/10/2023.
//

import UIKit
import SwiftUI
import BlazeSDK

// Just to be able to put SwiftUI inside existing TabViewController
final class SwiftUIHomeViewController: UIHostingController<SwiftUIHomeView> {
    private let homeView = SwiftUIHomeView()
    
    override init(rootView: SwiftUIHomeView) {
        super.init(rootView: homeView)
    }

    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder, rootView: homeView)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
}
