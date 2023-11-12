//
//  AdManager.swift
//  BlazeSDK-SampleApp
//
//  Created by Dor Zafrir on 08/11/2023.
//

import Foundation
import GoogleMobileAds
import UIKit

class AdManager: NSObject, GADAdLoaderDelegate, GADCustomNativeAdLoaderDelegate {
    
    static let sharedInstance = AdManager()
    
    private var currentAdRequests = [NativeAdRequest]()
    
    /// Load a single ad from Google and wait for it's result to return.
    ///
    /// - Parameters:
    ///   - adUnitId: adUnit to load.
    ///   - templateId: templateId.
    ///   - additionalParams: additionalParams
    /// - Returns: the loaded ad, or nil if any error occured.
    func getNativeAd(adUnitId: String,
                     templateId: String,
                     additionalParams: [String: String]) async -> GADCustomNativeAd? {
        return await withCheckedContinuation { continuation in
            AdManager.sharedInstance.getNativeAd(
                adUnitId: adUnitId,
                templateId: templateId,
                additionalParams: additionalParams) { ad, error in
                    if error == nil, let nativeAd = ad {
                        continuation.resume(returning: nativeAd)
                    } else {
                        continuation.resume(returning: nil)
                    }
                }
        }
    }
    
    private func getNativeAd(adUnitId: String,
                             templateId: String,
                             additionalParams: [String: String],
                             completion: @escaping (GADCustomNativeAd?, Error?) -> Void) {
        let adLoader = GADAdLoader(
            adUnitID: adUnitId,
            rootViewController: nil,
            adTypes: [GADAdLoaderAdType.customNative],
            options: nil)
        adLoader.delegate = self
        
        let request = GADRequest()
        
        let extras = GADExtras()
        extras.additionalParameters = additionalParams
        request.register(extras)
        
        let nativeAdRequest = NativeAdRequest(adLoader: adLoader,
                                              completion: completion,
                                              templateId: templateId)
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.currentAdRequests.append(nativeAdRequest)
            adLoader.load(request)
        }
    }
    
    func customNativeAdFormatIDs(for adLoader: GADAdLoader) -> [String] {
        let templateId = currentAdRequests.first { nativeAdRequest in
            nativeAdRequest.adLoader == adLoader
        }?.templateId ?? ""
        
        return [templateId]
    }
    
    func adLoader(_ adLoader: GADAdLoader, didReceive customNativeAd: GADCustomNativeAd) {
        guard let nativeAdRequest = currentAdRequests.first(where: { nativeAdRequest in
            nativeAdRequest.adLoader == adLoader
        }) else { return }
        nativeAdRequest.completion(customNativeAd, nil)
        removeAdRequest(adRequest: nativeAdRequest)
    }
    
    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: Error) {
        guard let nativeAdRequest = currentAdRequests.first(where: { nativeAdRequest in
            nativeAdRequest.adLoader == adLoader
        }) else { return }
        nativeAdRequest.completion(nil, error)
        removeAdRequest(adRequest: nativeAdRequest)
    }
    
    private func removeAdRequest(adRequest: NativeAdRequest) {
        currentAdRequests.removeAll(where: { $0 == adRequest })
    }
}

