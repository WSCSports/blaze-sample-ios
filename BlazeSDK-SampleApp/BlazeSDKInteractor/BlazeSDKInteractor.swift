//
//  BlazeSDKInteractor.swift
//  BlazeSDK-SampleApp
//
//  Created by Dor Zafrir on 19/07/2023.
//

import Foundation
import BlazeSDK
import UIKit

final class BlazeSDKInteractor {
    
    struct Constants {
        static let defaultCacheSize = 500
        static let apiKey = "[API - KEY]"
        static let storiesRowLabel = "[stories label]"
        static let storiesGridLabel = "[stories label]"
        static let momentsRowLabel = "[moments label]"
        static let momentsGridLabel = "[moments label]"
        static let momentsContainerTabLabel = "[moments Container label]"
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
    private(set) var momentsContainerTabLabel: String = Constants.momentsContainerTabLabel
    
    private var momentsContainersDic: [String: BlazeMomentsPlayerContainer] = [:]
    
    func initBlazeSDK() {
        Blaze.shared.initialize(apiKey: apiKey, cachingSize: cachingSize, prefetchingPolicy: prefetchLevel, geo: nil) { [weak self] result in
            self?.handleBlazeSdkInitalResult(for: result)
        }
        
        blazeSdk.adsHandler = AdsHandler()
        blazeSdk.delegate = self
    }
    
    func dismissCurrentPlayer() {
        blazeSdk.dismissCurrentPlayer()
    }
    
    func generateMomentsTab(containerId: String, dataSourceType: BlazeDataSourceType, momentsAppearance: BlazeMomentsAppearance? = nil, delegate: BlazePlayerContainerDelegate? = nil) {
        let playerContainer = BlazeMomentsPlayerContainer(dataSourceType: dataSourceType, containerDelegate: delegate, containerIdentifier: containerId, appearance: momentsAppearance)
        momentsContainersDic[containerId] = playerContainer
    }
    
    
    func playMomentsInContainer(containerId: String, containerVC: UIViewController, containerView: UIView? = nil) {
        guard let playerContainer = momentsContainersDic[containerId] else { return }
        playerContainer.startPlaying(in: containerVC, containerView: containerView)
    }
    
    private func handleBlazeSdkInitalResult(for result: BlazeResult) {
        switch result {
        case .success:
            print("SDK successfully initialized")
        case .failure(let error):
            print("Error message in blaze sdk: \(error.errorMessage)")
        }
//
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
