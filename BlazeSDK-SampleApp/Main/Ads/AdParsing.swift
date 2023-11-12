//
//  AdParsing.swift
//  BlazeSDK-SampleApp
//
//  Created by Dor Zafrir on 08/11/2023.
//

import Foundation
import GoogleMobileAds
import BlazeSDK

extension GADCustomNativeAd {
    
    func toAdModel() -> BlazeAdModel? {
        guard let creativeType = string(forKey: Ads.creativeTypeKey),
              let clickURL = string(forKey: Ads.clickURLKey),
              let advertiserName = string(forKey: Ads.advertiserNameKey),
              let trackingURL = string(forKey: Ads.trackingURLKey),
              let clickType = string(forKey: Ads.clickTypeKey),
              let clickThroughCTA = string(forKey: Ads.clickThroughCTAKey) else {
            return nil
        }

        var content: BlazeAdModel.Content?
        switch creativeType {
        case Ads.displayType:
            if let imageUrl = image(forKey: Ads.imageKey)?.imageURL?.absoluteString {
                content = .image(urlString: imageUrl, duration: 5)
            }
            
        case Ads.videoType:
            if let videoUrl = string(forKey: Ads.videoKey) {
                let previewImageUrl = string(forKey: Ads.videoPreviewImageUrlKey)
                content = .video(urlString: videoUrl, loadingImageUrl: previewImageUrl)
            }
            
        default:
            break
        }
        
        // Content must be provided.
        guard let content = content else {
            return nil
        }
        
        var cta: BlazeAdModel.CtaModel?
        switch clickType {
        case Ads.webKey:
            cta = .init(type: .web,
                        url: clickURL,
                        text: clickThroughCTA)
        case Ads.inAppKey:
            cta = .init(type: .deeplink,
                        url: clickURL,
                        text: clickThroughCTA)
        default:
            break
        }
        
        let trackingPixels: Set<BlazeAdModel.TrackingPixel> = [
            .init(eventType: .openedAd,
                  url: trackingURL)
        ]
        
        let adModel = BlazeAdModel(content: content,
                              title: advertiserName,
                              cta: cta,
                              trackingPixelAdList: trackingPixels,
                              customAdditionalData: CustomAdData(nativeAd: self),
                              analyticsData: .init(advertiserId: "some advertiserId",
                                                   advertiserName: "some advertiserName",
                                                   campaignId: "some campaignId",
                                                   campaignName: "some campaignName",
                                                   adServer: "some adServer"))

        return adModel
    }
    
}

