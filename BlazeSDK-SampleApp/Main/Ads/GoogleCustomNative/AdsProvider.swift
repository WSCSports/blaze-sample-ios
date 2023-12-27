//
//  AdsProvider.swift
//  BlazeSDK-SampleApp
//
//  Created by Dor Zafrir on 08/11/2023.
//

import Foundation
import BlazeSDK

class AdsProvider {
    
    struct Constants {
        static let adUnit = "[Your default ad unit id]"
        static let templateId = "[Your default template id]"
    }
    
    func generateAd(adRequestData: BlazeAdRequestData) async -> BlazeGoogleCustomNativeAdModel? {
        let ad = await AdManager.sharedInstance.getNativeAd(adUnitId: adRequestData.adInfo?.adUnitId ?? Constants.adUnit,
                                                            templateId: adRequestData.adInfo?.formatId ?? Constants.templateId,
                                                            additionalParams: adRequestData.adInfo?.context ?? [:])
        let adModel = ad?.toAdModel()
        return adModel
    }
    
}
