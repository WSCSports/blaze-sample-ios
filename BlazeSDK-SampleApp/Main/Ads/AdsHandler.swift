//
//  AdsHandler.swift
//  BlazeSDK-SampleApp
//
//  Created by Dor Zafrir on 08/11/2023.
//

import Foundation
import BlazeSDK
import GoogleMobileAds

class AdsHandler: BlazeAdsHandler {
    let adsProvider = AdsProvider()
    
    func onAdEvent(eventType: BlazeAdsHandlerEventType, adModel: BlazeAdModel) {
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
    
    func provideAd(adRequestData: BlazeAdRequestData) async -> BlazeAdModel? {
        let ads = await adsProvider.generateAd(adRequestData: adRequestData)
        return ads
    }
    
    
}

