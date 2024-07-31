//
//  BlazeSDKInteractor.swift
//  BlazeSDK-SampleApp
//
//  Created by Dor Zafrir on 19/07/2023.
//

import Foundation
import BlazeSDK
import UIKit
import BlazeGAM
import BlazeIMA
import GoogleInteractiveMediaAds

final class BlazeSDKInteractor {
    
    struct Constants {
        static let defaultCacheSize = 500
        static let apiKey = "[API - KEY]"
        static let storiesRowLabel = "live-stories"
        static let storiesGridLabel = "top-stories"
        static let momentsRowLabel = "moments"
        static let momentsGridLabel = "moments"
        static let momentsContainerTabLabel = "moments"
        static let adUnit = "[Your default ad unit id]"
        static let templateId = "[Your default template id]"
    }
    
    static var shared: BlazeSDKInteractor = BlazeSDKInteractor()
    
    private let blazeSdk = Blaze.shared
    
    private var prefetchLevel: BlazeCachePolicyLevel = .Default
    private var apiKey: String = Constants.apiKey
    private var cachingSize: Int = Constants.defaultCacheSize
    private(set) var storiesRowWidgetLabel: String = Constants.storiesRowLabel
    private(set) var storiesGridWidgetLabel: String = Constants.storiesGridLabel
    private(set) var momentsRowWidgetLabel: String = Constants.momentsRowLabel
    private(set) var momentsGridWidgetLabel: String = Constants.momentsGridLabel
    private(set) var momentsContainerTabLabel: String = Constants.momentsContainerTabLabel
    
    private var momentsContainersDic: [String: BlazeMomentsPlayerContainer] = [:]
    
    private lazy var gamDelegate = createBlazeGAMDelegate()
    
    private lazy var imaDelegate = createBlazeIMADelegate()
    
    func initBlazeSDK() {
        blazeSdk.initialize(apiKey: apiKey, cachingSize: cachingSize, prefetchingPolicy: prefetchLevel, geo: nil) { [weak self] result in
            self?.handleBlazeSdkInitalResult(for: result)
        }
        
        setupBlazeGlobalDelegate()
    }
    
    func dismissCurrentPlayer() {
        blazeSdk.dismissCurrentPlayer()
    }
    
    func generateMomentsTab(containerId: String,
                            dataSourceType: BlazeDataSourceType,
                            momentsPlayerStyle: BlazeMomentsPlayerStyle? = nil,
                            delegate: BlazePlayerContainerDelegate? = nil) {
        let playerContainer = BlazeMomentsPlayerContainer(dataSourceType: dataSourceType , containerDelegate: delegate, containerIdentifier: containerId, style: momentsPlayerStyle)
        playerContainer.prepareMoments()
        momentsContainersDic[containerId] = playerContainer
    }
    
    
    func playMomentsInContainer(containerId: String, containerVC: UIViewController, containerView: UIView? = nil) {
        guard let playerContainer = momentsContainersDic[containerId] else { return }
        playerContainer.startPlaying(in: containerVC, containerView: containerView)
    }
    
    private func handleBlazeSdkInitalResult(for result: BlazeResult) {
        switch result {
        case .success:
            DispatchQueue.main.async { [weak self] in
                self?.handleSDKSuccessResult()
            }
        case .failure(let error):
            print("Error message in blaze sdk: \(error.errorMessage)")
        }
    }
    
    private func setupBlazeGlobalDelegate() {
        blazeSdk.delegate.onEventTriggered = onEventTriggered()
        blazeSdk.delegate.onErrorThrown = { [weak self] error in
            self?.onErrorThrown(error)
        }
    }
    
    private func handleSDKSuccessResult() {
        BlazeGAM.shared.enableCustomNativeAds(defaultAdsConfig: .init(adUnit: Constants.adUnit,
                                                                      templateId: Constants.templateId),
                                              delegate: gamDelegate)
        BlazeIMA.shared.enableAds(delegate: imaDelegate)
    }
}

extension BlazeSDKInteractor {
    // Return the handler
    func onEventTriggered() -> BlazeSDKDelegate.OnEventTriggeredHandler {
        { eventData in
            print("onEventTriggered delegate, eventData: \(eventData)")
        }
    }
    
    // Perform a function inside the handler
    func onErrorThrown(_ error: BlazeError) {
        print("onErrorThrown delegate, error: \(error.errorMessage)")
    }
}

// MARK: - BlazeGAMDelegate
extension BlazeSDKInteractor {
    private func createBlazeGAMDelegate() -> BlazeGAMDelegate {
        BlazeGAMDelegate(onGAMAdError: { [weak self] error in
            self?.onGAMAdError(error.localizedDescription)
        },
                         onGAMAdEvent: { [weak self] params in
            self?.onGAMAdEvent(eventType: params.eventType, adData: params.adData)
        }, customGAMTargetingProperties: { [weak self] in
            self?.customGAMProperties() ?? [:]
        })
    }
    
    private func onGAMAdEvent(eventType: BlazeGoogleCustomNativeAdsHandlerEventType, adData: BlazeCustomAdData) {
        print("Received Ad event of type: \(eventType), for ad: \(adData)")
    }
    
    private func onGAMAdError(_ error: String) {
        print("Received Ad error: \(error)")
    }
    
    private func customGAMProperties() -> [String: String] {
        return [:]
        // For Example if you want to add consent and npa
        /*
         let npaKey = "npa"
         let gdprKey = "gdpr"
         return [npaKey: "0", gdprKey: "0"]
         */
    }
}

//MARK: BlazeIMADelegate
extension BlazeSDKInteractor {
    
    private func createBlazeIMADelegate() -> BlazeIMADelegate {
        BlazeIMADelegate(onIMAAdError: { [weak self] error in
            self?.onIMAAdError(error)
        },
                         onIMAAdEvent: { [weak self] params in
            self?.onIMAAdEvent(eventType: params.eventType,
                               adInfo: params.adInfo)
        },
                         additionalIMATagQueryParams: { [weak self] in
            return self?.adExtraParams() ?? [:]
        }, customIMASettings: { [weak self] in
            return self?.customIMASettings()
        })
    }
    
    private func onIMAAdEvent(eventType: BlazeIMAHandlerEventType, adInfo: BlazeImaAdInfo) {
        print("Received Ad event of type: \(eventType), for ad: \(adInfo)")
    }
    
    private func onIMAAdError(_ error: String) {
        print("Received Ad error: \(error)")
    }
    
    private func adExtraParams() -> [String: String] {
        return [:]
        // For Example if you want to add consent and npa params to your tag
        /*
         let npaKey = "npa"
         let gdprKey = "gdpr"
         return [npaKey: "0", gdprKey: "0"]
         */
    }
    
    private func customIMASettings() -> IMASettings {
        let imaSettings = IMASettings()
        
        // For example if you want to change the ima language
        /*
         imaSettings.language = "es"
         */
        return imaSettings
    }
}
