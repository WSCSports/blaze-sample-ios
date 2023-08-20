//
//  BlazeSDKInteractor.swift
//  BlazeSDK-SampleApp
//
//  Created by Dor Zafrir on 19/07/2023.
//

import Foundation
import BlazeSDK

final class BlazeSDKInteractor {
    
    struct Constants {
        static let defaultCacheSize = 500
        static let apiKey = "[API - KEY]"
        static let storiesRowLabel = "live-stories"
        static let storiesGridLabel = "top-stories"
        static let momentsRowLabel = "moments"
        static let momentsGridLabel = "moments"
    }
    
    static var shared: BlazeSDKInteractor = BlazeSDKInteractor()
    
    private let blazeSdk = Blaze.shared
    
    private var prefetchLevel: CachePolicyLevel = .Default
    private var apiKey: String = Constants.apiKey
    private var cachingSize: Int = Constants.defaultCacheSize
    private(set) var storiesRowWidgetLabel: String = Constants.storiesRowLabel
    private(set) var storiesGridWidgetLabel: String = Constants.storiesGridLabel
    private(set) var momentsRowWidgetLabel: String = Constants.momentsRowLabel
    private(set) var momentsGridWidgetLabel: String = Constants.momentsGridLabel
    
    func initBlazeSDK() {
        Blaze.shared.initialize(apiKey: apiKey, cachingSize: cachingSize, prefetchingPolicy: prefetchLevel) { [weak self] error in
            self?.handleBlazeSdkInitalError(for: error)
        }
        
        blazeSdk.delegate = self
    }
    
    func dismissCurrentPlayer() {
        blazeSdk.dismissCurrentPlayer()
    }
    
    private func handleBlazeSdkInitalError(for error: BlazeError) {
        print("Error message in blaze sdk: \(error.errorMessage)")
    }
}

extension BlazeSDKInteractor: BlazeSDKDelegate {
    func onErrorThrown(_ error: BlazeError) {
        print("onErrorThrown delegate, error: \(error.errorMessage)")
    }
    
    func onEventTriggered(eventType: BlazeAnalytics.EventType, eventData: BlazeAnalytics.EventData) {
        print("onEventTriggered delegate, eventType: \(eventType), eventData: \(eventData)")
    }
    
    func onStoryPlayerDidAppear() {
        print("onStoryPlayerDidAppear delegate")
    }
    
    func onStoryPlayerDismissed() {
        print("onStoryPlayerDismissed delegate")
    }
    
    func onMomentsPlayerDidAppear() {}
    func onMomentsPlayerDismissed() {}
    
    
}
