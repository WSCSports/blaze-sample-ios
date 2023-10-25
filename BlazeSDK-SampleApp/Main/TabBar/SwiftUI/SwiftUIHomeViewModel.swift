//
//  SwiftUIHomeViewModel.swift
//  BlazeSDK-SampleApp
//
//  Created by Dor Zafrir on 24/10/2023.
//

import Foundation
import BlazeSDK
import SwiftUI


final class HomeViewModel: ObservableObject {
    
    private static var storiesRowDataSourceType: BlazeDataSourceType = .labels(.singleLabel(BlazeSDKInteractor.shared.storiesRowWidgetLabel))
    private static var momentsRowDataSourceType: BlazeDataSourceType = .labels(.singleLabel(BlazeSDKInteractor.shared.momentsRowWidgetLabel))
    private static var storiesGridDataSourceType: BlazeDataSourceType = .labels(.singleLabel(BlazeSDKInteractor.shared.storiesGridWidgetLabel))
    
    @Published var storiesRowViewModel: BlazeSwiftUIStoriesWidgetViewModel!
    @Published var storiesGridViewModel: BlazeSwiftUIStoriesWidgetViewModel!
    @Published var momentsRowViewModel: BlazeSwiftUIMomentsWidgetViewModel!
        
    init() {
        setupWidgets()
    }
    
    
    private func setupWidgets() {
        // setup stories row widget
        self.storiesRowViewModel = BlazeSwiftUIStoriesWidgetViewModel(widgetConfiguration: BlazeSwiftUIWidgetConfiguration(layout: BlazeSwiftUIStoriesRowWidgetView.singleItemHorizontalRectangleLayout(), dataSourceType: HomeViewModel.storiesRowDataSourceType), delegate: self)

        // setup moments row widget
        self.momentsRowViewModel = BlazeSwiftUIMomentsWidgetViewModel(dataSourceType: HomeViewModel.momentsRowDataSourceType, layout: BlazeSwiftUIMomentsRowWidgetView.rectangleLayout(), delegate: self)

        // setup stories grid widget
        let storiesGridConfiguration = BlazeSwiftUIWidgetConfiguration(layout: BlazeSwiftUIStoriesGridWidgetView.twoColumnGridLayout(), dataSourceType: HomeViewModel.storiesGridDataSourceType, sizeLimit: 4, adjustSizeAutomatically: true)
        self.storiesGridViewModel = BlazeSwiftUIStoriesWidgetViewModel(widgetConfiguration: storiesGridConfiguration, delegate: self)
    }
    
    
    func reloadData(progressType: ProgressType) {
        storiesRowViewModel.reloadData(progressType: progressType)
        momentsRowViewModel.reloadData(progressType: progressType)
        storiesGridViewModel.reloadData(progressType: progressType)
    }
    
    func setStoriesRowLayout(_ layout: BlazeWidgetLayout) {
        storiesRowViewModel.setLayout(layout)
    }

    func setMomentsRowLayout(_ layout: BlazeWidgetLayout) {
        momentsRowViewModel.setLayout(layout)
    }

    func setStoriesRowDataSourceType(_ dataSourceType: BlazeDataSourceType, progressType: ProgressType) {
        storiesRowViewModel.updateDataSourceType(dataSourceType, progressType: progressType)
    }

    func setMomentsRowDataSourceType(_ dataSourceType: BlazeDataSourceType, progressType: ProgressType) {
        momentsRowViewModel.updateDataSourceType(dataSourceType, progressType: progressType)
    }
}

extension HomeViewModel: WidgetDelegate {
    func onWidgetDataLoadStarted(widgetId: String) {
        print("onWidgetDataLoadStarted event. widgetId: \(widgetId)")
    }
    
    func onWidgetDataLoadComplete(widgetId: String, itemsCount: Int, result: BlazeSDK.BlazeResult) {
        print("onWidgetDataLoadComplete event. widgetId: \(widgetId), itemsCount: \(itemsCount)")
    }
    
    func onWidgetPlayerDismissed(widgetId: String) {
        print("onWidgetPlayerDismissed event. widgetId: \(widgetId)")
    }
    
    func onTriggerCTA(widgetId: String, actionType: String, actionParam: String) -> Bool {
        // On false the SDK will handle the CTA
        return false
    }
    
    
}
