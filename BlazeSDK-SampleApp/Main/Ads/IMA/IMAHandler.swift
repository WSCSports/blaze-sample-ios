//
//  IMAHandler.swift
//  BlazeSDK-SampleApp
//
//  Created by Dor Zafrir on 24/12/2023.
//

import UIKit
import GoogleInteractiveMediaAds
import BlazeSDK

class IMAHandler: NSObject, BlazeIMAHandlerProtocol {

    private var adsLoader: IMAAdsLoader?
    private var adsManager: IMAAdsManager?

    private var volume: Float = 0 {
        didSet {
            adsManager?.volume = volume
        }
    }

    weak var delegate: BlazeIMAHandlerDelegate?
    
    override init() {
        super.init()
        setupNotificationObservers()
    }
    
    
    func requestAds(adContainerView: UIView, adVC: UIViewController, adTag: String, initialVolume: Float) {
        // Create ad display container for ad rendering.
        self.volume = initialVolume
        adsLoader = nil
        adsManager?.destroy()
        adsLoader = IMAAdsLoader(settings: nil)
        adsLoader?.delegate = self
        let adDisplayContainer = IMAAdDisplayContainer(adContainer: adContainerView, viewController: adVC, companionSlots: nil)
        // Create an ad request with our ad tag, display container, and optional user context.
        let request = IMAAdsRequest(
            adTagUrl: adTag,
            adDisplayContainer: adDisplayContainer,
            contentPlayhead: nil,
            userContext: nil)

        adsLoader?.requestAds(with: request)
    }

    func updateVolume(to volume: Float) {
        self.volume = volume
    }
    
    private func blazeAdInfo(for ad: IMAAd?) -> BlazeImaAdInfo {
        return BlazeImaAdInfo(adId: ad?.adId, adTitle: ad?.adTitle, adDescription: ad?.adDescription, adSystem: ad?.adSystem, isSkippable: ad?.isSkippable, skipTimeOffset: ad?.skipTimeOffset, adDuration: ad?.duration, advertiserName: ad?.advertiserName)
    }
}

extension IMAHandler: IMAAdsLoaderDelegate {

    func adsLoader(_ loader: IMAAdsLoader, adsLoadedWith adsLoadedData: IMAAdsLoadedData) {
        adsManager = adsLoadedData.adsManager
        adsManager?.delegate = self
        // Initialize the ads manager.
        adsManager?.initialize(with: nil)
        adsManager?.volume = self.volume
    }

    func adsLoader(_ loader: IMAAdsLoader, failedWith adErrorData: IMAAdLoadingErrorData) {
        let errorMessgae = "BlazeIMAHandler error loading ads: \(adErrorData.adError.message ?? "Unknown")"
        delegate?.onAdError(errorMessgae)
    }
}
    // MARK: - IMAAdsManagerDelegate
extension IMAHandler: IMAAdsManagerDelegate {

    func adsManager(_ adsManager: IMAAdsManager, didReceive event: IMAAdEvent) {
        let adInfo = blazeAdInfo(for: event.ad)
        
        switch event.type {
        case .LOADED:
            adsManager.start()
            delegate?.onAdEvent(eventType: .adLoaded, adInfo: adInfo)
        case .ALL_ADS_COMPLETED:
            delegate?.onAdEvent(eventType: .allAdsCompleted, adInfo: adInfo)
            self.adsManager = nil
        case .CLICKED:
            delegate?.onAdEvent(eventType: .adClicked, adInfo: adInfo)
        case .COMPLETE:
            delegate?.onAdEvent(eventType: .adCompleted, adInfo: adInfo)
        case .FIRST_QUARTILE:
            delegate?.onAdEvent(eventType: .adFirstQuartile, adInfo: adInfo)
        case .MIDPOINT:
            delegate?.onAdEvent(eventType: .adMidpoint, adInfo: adInfo)
        case .PAUSE:
            delegate?.onAdEvent(eventType: .adPaused, adInfo: adInfo)
        case .RESUME:
            delegate?.onAdEvent(eventType: .adResumed, adInfo: adInfo)
        case .SKIPPED:
            delegate?.onAdEvent(eventType: .adSkipped, adInfo: adInfo)
        case .STARTED:
            delegate?.onAdEvent(eventType: .adStarted, adInfo: adInfo)
        case .TAPPED:
            delegate?.onAdEvent(eventType: .adTapped, adInfo: adInfo)
        case .THIRD_QUARTILE:
            delegate?.onAdEvent(eventType: .adThirdQuartile, adInfo: adInfo)
        default: break
        }
    }

    func adsManager(_ adsManager: IMAAdsManager, didReceive error: IMAAdError) {
        let errorMessgae = "BlazeIMAHandler error: \(error.message ?? "Unknown")"
        delegate?.onAdError(errorMessgae)
        self.adsManager = nil
    }

    func adsManagerDidRequestContentPause(_ adsManager: IMAAdsManager) {
        // The SDK is going to play ads, so pause any other content.
    }

    func adsManagerDidRequestContentResume(_ adsManager: IMAAdsManager) {
      // The SDK is done playing ads (at least for now), so resume the content.
    }

}

extension IMAHandler {
    
    private func setupNotificationObservers() {
        
        NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: .main) { [weak self] _ in
            self?.appDidBecomeActive()
        }
        
    }
    
    // Handle app did become active
    private func appDidBecomeActive() {
        adsManager?.resume()
    }
    
}
