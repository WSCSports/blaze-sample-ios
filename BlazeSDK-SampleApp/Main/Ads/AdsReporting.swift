//
//  AdsReporting.swift
//  BlazeSDK-SampleApp
//
//  Created by Dor Zafrir on 08/11/2023.
//

import Foundation
import GoogleMobileAds
import BlazeSDK

extension BlazeAdModel {
    
    func reportAdImpression() {
        nativeAd?.recordImpression()
    }
    
    func trackEnteredViewability(adView: UIView?) {
        nativeAd?.displayAdMeasurement?.view = adView

        do {
            try nativeAd?.displayAdMeasurement?.start()
        } catch {
            print("Ad Error: \(error)")
        }
    }
    
    func reportCTAClicked() {
        let assetKey: String
        switch content {
        case .image:
            assetKey = Ads.imageKey
        case .video:
            assetKey = Ads.videoKey
        }

        nativeAd?.customClickHandler = { _ in }
        nativeAd?.performClickOnAsset(withKey: assetKey)
    }

    
    var nativeAd: GADCustomNativeAd? {
        return (customAdditionalData as? CustomAdData)?.nativeAd
    }
}
