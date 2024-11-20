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
import GoogleMobileAds

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
    
    private lazy var gamCustomNativeDelegate = createBlazeGAMCustomNativeDelegate()
    
    private lazy var gamBannersDelegate = createBlazeGAMBannersDelegate()
    
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
        BlazeGAM.shared.enableCustomNativeAds(defaultCustomNativeAdsConfig: .init(adUnit: Constants.adUnit,
                                                                      templateId: Constants.templateId),
                                              delegate: gamCustomNativeDelegate)
        
        BlazeIMA.shared.enableAds(delegate: imaDelegate)
        BlazeGAM.shared.enableBannerAds(delegate: gamBannersDelegate)
    }
}

// MARK: - BlaskSDKDelegate Handlers
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

// MARK: - BlazeGAMCustomNativeDelegate

extension BlazeSDKInteractor {
    
    private func createBlazeGAMCustomNativeDelegate() -> BlazeGAMCustomNativeAdsDelegate {
        let onGAMAdError: BlazeGAMCustomNativeAdsDelegate.OnGAMAdErrorHandler = { [weak self] error in
            self?.onGAMCustomNativeAdError(error.localizedDescription)
        }
        let onGAMAdEvent: BlazeGAMCustomNativeAdsDelegate.OnGAMAdEventHandler = { [weak self] params in
            self?.onGAMCustomNativeAdEvent(eventType: params.eventType, adData: params.adData)
        }
        let customGAMTargetingProperties: BlazeGAMCustomNativeAdsDelegate.CustomGAMTargetingPropertiesHandler = { [weak self] in
            self?.customGAMCustomNativeAdsProperties() ?? [:]
        }
        
        let publisherProvidedId: BlazeGAMCustomNativeAdsDelegate.PublisherProvidedIdHandler = { [weak self] in
            self?.gamCustomNativePublisherProvidedId()
        }

        let networkExtras: BlazeGAMCustomNativeAdsDelegate.NetworkExtrasHandler = { [weak self] in
            self?.gamCustomNativeNetworkExtras()
        }
        
        return BlazeGAMCustomNativeAdsDelegate(onGAMAdError: onGAMAdError,
                                               onGAMAdEvent: onGAMAdEvent,
                                               customGAMTargetingProperties: customGAMTargetingProperties,
                                               publisherProvidedId: publisherProvidedId,
                                               networkExtras: networkExtras)
    }
    
    private func onGAMCustomNativeAdEvent(eventType: BlazeGoogleCustomNativeAdsHandlerEventType, adData: BlazeCustomNativeAdData) {
        print("Received Custom Native Ad event of type: \(eventType), for ad: \(adData)")
    }
    
    private func onGAMCustomNativeAdError(_ error: String) {
        print("Received Custom Native Ad error: \(error)")
    }
    
    private func customGAMCustomNativeAdsProperties() -> [String: String] {
        return [:]
        // For Example if you want to add consent and npa
        /*
         let npaKey = "npa"
         let gdprKey = "gdpr"
         return [npaKey: "0", gdprKey: "0"]
         */
    }
    
    private func gamCustomNativePublisherProvidedId() -> String? {
        return nil
        // For Example if you want to add publisher provided id
        /*
         return "custom publisher provided id"
         */
        
    }
    
    private func gamCustomNativeNetworkExtras() -> GADExtras? {
        return nil
        // For Example if you want to add network extras
        /*
         let extras = GADExtras()
         extras.additionalParameters = ["custom network extras string": "test",
                                      "custom network extras int": 5,
                                      "custom network extras bool": true]
         return extras
         */
    }
    
}

// MARK: - BlazeGAMBannersDelegate

extension BlazeSDKInteractor {
    
    private func createBlazeGAMBannersDelegate() -> BlazeGAMBannerAdsDelegate {
        let onGAMBannerAdsAdError: BlazeGAMBannerAdsDelegate.OnGAMBannerAdsAdErrorHandler = { [weak self] params in
            self?.onGAMBannersAdError(params.error.localizedDescription)
        }
        let onGAMBannerAdsAdEvent: BlazeGAMBannerAdsDelegate.OnGAMBannerAdsAdEventHandler = { [weak self] params in
            self?.onGAMBannersAdEvent(eventType: params.eventType, adData: params.adData)
        }
        
        return BlazeGAMBannerAdsDelegate(onGAMBannerAdsAdError: onGAMBannerAdsAdError,
                                  onGAMBannerAdsAdEvent: onGAMBannerAdsAdEvent)
    }
    
    private func onGAMBannersAdEvent(eventType: BlazeGAMBannerHandlerEventType, adData: BlazeGAMBannerAdsAdData) {
        print("Received Banner Ad event of type: \(eventType), for ad: \(adData)")
    }
    
    private func onGAMBannersAdError(_ error: String) {
        print("Received Banner Ad error: \(error)")
    }
    
}


//MARK: BlazeIMADelegate

extension BlazeSDKInteractor {
    
    private func createBlazeIMADelegate() -> BlazeIMADelegate {
        let onImAAdError: BlazeIMADelegate.OnIMAAdErrorHandler = { [weak self] error in
            self?.onIMAAdError(error)
        }
        let onImAAdEvent: BlazeIMADelegate.OnIMAAdEventHandler = { [weak self] params in
            self?.onIMAAdEvent(eventType: params.eventType,
                               adInfo: params.adInfo)
        }
        let additionalIMATagQueryParams: BlazeIMADelegate.AdditionalIMATagQueryParamsHandler = { [weak self] in
            self?.adExtraParams() ?? [:]
        }
        let customIMASettings: BlazeIMADelegate.CustomIMASettingsHandler = { [weak self] in
            self?.customIMASettings()
        }
        let overrideAdTagUrl: BlazeIMADelegate.OverrideAdTagUrlHandler = { [weak self] in
            self?.overrideAdTagUrl()
        }
        
        return BlazeIMADelegate(onIMAAdError: onImAAdError,
                                onIMAAdEvent: onImAAdEvent,
                                additionalIMATagQueryParams: additionalIMATagQueryParams,
                                customIMASettings: customIMASettings,
                                overrideAdTagUrl: overrideAdTagUrl)
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
    
    private func overrideAdTagUrl() -> String? {
        return nil
        // For example if you want to override the ad tag url
        /*
         return "overrideAdTagUrl"
         */
    }
    
}
