//
//  HomeViewController.swift
//  BlazeSDK-SampleApp
//
//  Created by Dor Zafrir on 19/07/2023.
//

import UIKit
import BlazeSDK

class HomeViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var viewToEmbedRowView: UIView!
    @IBOutlet weak var viewToEmbedGridView: UIView!
    
    private var storiesRowWidgetView: BlazeStoriesWidgetRowView?
    private var storiesGridWidgetView: BlazeStoriesWidgetGridView?
    
    private lazy var widgetDelegate = createWidgetDelegate()
    
    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(pullToRefreshTriggered), for: .valueChanged)
        return refreshControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupStoriesRowWidget()
        setupStoriesGridWidget()
        scrollView.refreshControl = refreshControl
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated:true)
    }
    
    private func setupStoriesRowWidget() {
        var layout = BlazeWidgetLayout.Presets.StoriesWidget.Row.circles
        storiesRowWidgetView = BlazeStoriesWidgetRowView(layout: layout)
        storiesRowWidgetView?.widgetDelegate = widgetDelegate
        storiesRowWidgetView?.embedInView(viewToEmbedRowView)
        storiesRowWidgetView?.dataSourceType = .labels(.singleLabel(BlazeSDKInteractor.shared.storiesRowWidgetLabel))
        storiesRowWidgetView?.widgetIdentifier = "Recent Stories widget"
        storiesRowWidgetView?.reloadData(progressType: .skeleton)
    }
    
    private func setupStoriesGridWidget() {
        var layout = BlazeWidgetLayout.Presets.StoriesWidget.Grid.twoColumnsVerticalRectangles
        storiesGridWidgetView = BlazeStoriesWidgetGridView(layout: layout)
        storiesGridWidgetView?.widgetDelegate = widgetDelegate
        storiesGridWidgetView?.embedInView(viewToEmbedGridView)
        storiesGridWidgetView?.dataSourceType = .labels(.singleLabel(BlazeSDKInteractor.shared.storiesGridWidgetLabel), maxItems: 6)
        storiesGridWidgetView?.widgetIdentifier = "Top Stories widget"
        storiesGridWidgetView?.isEmbededInScrollView = true
        storiesGridWidgetView?.reloadData(progressType: .skeleton)
    }
    
    private func createWidgetDelegate() -> BlazeWidgetDelegate {
        .init { [weak self] params in
            self?.onDataLoadStarted(playerType: params.playerType,
                                    sourceId: params.sourceId)
        } onDataLoadComplete: { [weak self] params in
            self?.onDataLoadComplete(playerType: params.playerType,
                                     sourceId: params.sourceId,
                                     itemsCount: params.itemsCount,
                                     result: params.result)
        } onPlayerDidAppear: { [weak self] params in
            self?.onPlayerDidAppear(playerType: params.playerType,
                                    sourceId: params.sourceId)
        } onPlayerDidDismiss: { [weak self] params in
            self?.onPlayerDidDismiss(playerType: params.playerType,
                                     sourceId: params.sourceId)
        } onTriggerCTA: { [weak self] params in
            guard let self else { return false }
            return self.onTriggerCTA(playerType: params.playerType,
                                     sourceId: params.sourceId,
                                     actionType: params.actionType.rawValue,
                                     actionParam: params.actionParam)
        } onWidgetItemClicked: { [weak self] params in
            self?.onWidgetItemClicked(widgetId: params.widgetId, 
                                      widgetItemId: params.widgetItemId,
                                      widgetItemTitle: params.widgetItemTitle)
        }
        
    }
    
    private func handleDeepLink(action: String) {
        BlazeSDKInteractor.shared.dismissCurrentPlayer()
        print("handle deep link")
    }
    
    @objc func pullToRefreshTriggered(refreshControl: UIRefreshControl) {
        storiesRowWidgetView?.reloadData(progressType: .silent)
        storiesGridWidgetView?.reloadData(progressType: .silent)
    }
    
}

// MARK: - Widget Delegate Handlers

extension HomeViewController {
    
    func onDataLoadStarted(playerType: BlazePlayerType, sourceId: String?) {
        print("onDataLoadStarted delegate, widgetId: \(sourceId ?? "No source id provided")")
    }
    
    func onDataLoadComplete(playerType: BlazePlayerType, sourceId: String?, itemsCount: Int, result: BlazeResult) {
        refreshControl.endRefreshing()
        switch result {
        case .success():  print("onDataLoadComplete delegate, widgetId: \(sourceId ?? "No source id provided"), number of items: \(itemsCount)")
        case .failure(let error): print("onDataLoadComplete with error delegate, widgetId: \(sourceId ?? "No source id provided"), error: \(error.errorMessage)")
        }
    }
    
    func onPlayerDidDismiss(playerType: BlazePlayerType, sourceId: String?) {
        print("onPlayerDidDismiss delegate, widgetId: \(sourceId ?? "No source id provided")")
    }
    
    func onPlayerDidAppear(playerType: BlazePlayerType, sourceId: String?) {
        print("onPlayerDidAppear delegate, widgetId: \(sourceId ?? "No source id provided")")
    }
    
    func onTriggerCTA(playerType: BlazePlayerType, sourceId: String?, actionType: String, actionParam: String) -> Bool {
        print("onTriggerCTA delegate, widgetId: \(sourceId ?? "No source id provided"), actionType =\(actionType), actionParam: \(actionParam)")
        if actionType == "Web" {
            print("sdk will handle")
            return false
        } else if actionType == "Deeplink" {
            print("App will handle open")
            handleDeepLink(action: actionParam)
            return true
        }
        return false
    }
    
    func onWidgetItemClicked(widgetId: String, widgetItemId: String, widgetItemTitle: String?) {
        print("onWidgetItemClicked widgetId: \(widgetId), widgetItemId: \(widgetItemId), widgetItemTitle: \(widgetItemTitle ?? "No Widget Title")")
    }
}
