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
        static let apiKey = "[API KEY]"
        static let storiesRowLabel = "live-stories"
        static let storiesGridLabel = "top-stories"
    }
    
    static var shared: BlazeSDKInteractor = BlazeSDKInteractor()
    
    private let blazeSdk = Blaze.shared
    
    private var prefetchLevel: CachePolicyLevel = .High
    private var apiKey: String = Constants.apiKey
    private var cachingSize: Int = Constants.defaultCacheSize
    private(set) var storiesRowWidgetLabel: String = Constants.storiesRowLabel
    private(set) var storiesGridWidgetLabel: String = Constants.storiesGridLabel
    
    func initBlazeSDK() {
        Blaze.shared.initialize(apiKey: apiKey, cachingSize: cachingSize, prefetchingPolicy: prefetchLevel) { [weak self] error in
            self?.handleBlazeSdkInitalError(for: error)
        }
        
        blazeSdk.delegate = self
    }
    
    func dismissStoryPlayer() {
        blazeSdk.dismissCurrentPlayer()
    }
    
    private func handleBlazeSdkInitalError(for error: Error) {
        print("Error message in blaze sdk: \(error.localizedDescription)")
    }
}

extension BlazeSDKInteractor: BlazeSDKDelegate {
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
