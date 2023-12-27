//
//  NativeAdsRequest.swift
//  BlazeSDK-SampleApp
//
//  Created by Dor Zafrir on 08/11/2023.
//

import Foundation
import GoogleMobileAds

class NativeAdRequest: Equatable {
    static func == (lhs: NativeAdRequest, rhs: NativeAdRequest) -> Bool {
        lhs.adLoader == rhs.adLoader && lhs.templateId == rhs.templateId
    }

    init(adLoader: GADAdLoader,
         completion: @escaping (GADCustomNativeAd?, Error?) -> Void,
         templateId: String) {
        self.adLoader = adLoader
        self.completion = completion
        self.templateId = templateId
    }

    let adLoader: GADAdLoader
    let completion: (GADCustomNativeAd?, Error?) -> Void
    let templateId: String
}
