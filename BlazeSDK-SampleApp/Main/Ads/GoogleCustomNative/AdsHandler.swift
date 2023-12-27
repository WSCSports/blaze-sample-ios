//
//  AdsHandler.swift
//  BlazeSDK-SampleApp
//
//  Created by Dor Zafrir on 08/11/2023.
//

import Foundation
import BlazeSDK
import GoogleMobileAds

class AdsHandler: BlazeGoogleCustomNativeAdsHandler {
    
    let adsProvider = AdsProvider()
    
    func onAdEvent(eventType: BlazeGoogleCustomNativeAdsHandlerEventType, adModel: BlazeGoogleCustomNativeAdModel) {
        switch eventType {
        case .openedAd:
            // Report the ad impression to the ad provider.
            adModel.reportAdImpression()

        case .ctaClicked:
            // Report the ad click to the ad provider.
            adModel.reportCTAClicked()

        default:
            print("Received Ad event of type: \(eventType), for adModel: \(adModel)")
        }
    }
    
    func provideAd(adRequestData: BlazeAdRequestData) async -> BlazeGoogleCustomNativeAdModel? {
        let ads = await adsProvider.generateAd(adRequestData: adRequestData)
        return ads
    }
    
    
}

