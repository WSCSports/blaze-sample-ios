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
    private static var storiesGridDataSourceType: BlazeDataSourceType = .labels(.singleLabel(BlazeSDKInteractor.shared.storiesGridWidgetLabel), maxItems: 4)
    
    @Published var storiesRowViewModel: BlazeSwiftUIStoriesWidgetViewModel!
    @Published var storiesGridViewModel: BlazeSwiftUIStoriesWidgetViewModel!
    @Published var momentsRowViewModel: BlazeSwiftUIMomentsWidgetViewModel!
    
    private lazy var widgetDelegate = createWidgetDelegate()
        
    init() {
        setupWidgets()
    }
    
    
    private func setupWidgets() {
        // setup stories row widget
        self.storiesRowViewModel = BlazeSwiftUIStoriesWidgetViewModel(widgetConfiguration: BlazeSwiftUIWidgetConfiguration(layout: BlazeWidgetLayout.Presets.StoriesWidget.Row.singleItemHorizontalRectangle, dataSourceType: HomeViewModel.storiesRowDataSourceType), delegate: widgetDelegate)

        // setup moments row widget
        self.momentsRowViewModel = BlazeSwiftUIMomentsWidgetViewModel(dataSourceType: HomeViewModel.momentsRowDataSourceType, layout: BlazeWidgetLayout.Presets.MomentsWidget.Row.verticalRectangles, delegate: widgetDelegate)

        // setup stories grid widget
        let storiesGridConfiguration = BlazeSwiftUIWidgetConfiguration(layout: BlazeWidgetLayout.Presets.StoriesWidget.Grid.twoColumnsVerticalRectangles, dataSourceType: HomeViewModel.storiesGridDataSourceType, isEmbededInScrollView: true)
        self.storiesGridViewModel = BlazeSwiftUIStoriesWidgetViewModel(widgetConfiguration: storiesGridConfiguration, delegate: widgetDelegate)
    }
    
    
    func reloadData(progressType: BlazeProgressType) {
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

    func setStoriesRowDataSourceType(_ dataSourceType: BlazeDataSourceType, progressType: BlazeProgressType) {
        storiesRowViewModel.updateDataSourceType(dataSourceType, progressType: progressType)
    }

    func setMomentsRowDataSourceType(_ dataSourceType: BlazeDataSourceType, progressType: BlazeProgressType) {
        momentsRowViewModel.updateDataSourceType(dataSourceType, progressType: progressType)
    }
    
    private func createWidgetDelegate() -> BlazeWidgetDelegate {
        return BlazeWidgetDelegate(
            onDataLoadStarted: { [weak self] params in
                self?.onDataLoadStarted(playerType: params.playerType, sourceId: params.sourceId)
            },
            onTriggerCTA: { [weak self] params in
                guard let self else { return false }
                return self.onTriggerCTA(playerType: params.playerType,
                                         sourceId: params.sourceId,
                                         actionType: params.actionType,
                                         actionParam: params.actionParam)
            }
        )
    }
}

extension HomeViewModel {
    
    
    func onDataLoadStarted(playerType: BlazePlayerType, sourceId: String?) {
        print("onDataLoadStarted delegate, widgetId: \(sourceId ?? "No source id provided")")
    }
    
    func onTriggerCTA(playerType: BlazePlayerType, sourceId: String?, actionType: String, actionParam: String) -> Bool {
        return false
    }
    
}
