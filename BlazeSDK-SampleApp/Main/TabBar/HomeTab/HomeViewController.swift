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
        var layout = BlazeStoriesWidgetRowView.circleLayout()
        storiesRowWidgetView = BlazeStoriesWidgetRowView(layout: layout)
        storiesRowWidgetView?.widgetDelegate = self
        storiesRowWidgetView?.embedInView(viewToEmbedRowView)
        storiesRowWidgetView?.dataSourceType = .labels(.singleLabel(BlazeSDKInteractor.shared.storiesRowWidgetLabel))
        storiesRowWidgetView?.widgetIdentifier = "Recent Stories widget"
        storiesRowWidgetView?.reloadData(progressType: .skeleton)
    }
    
    private func setupStoriesGridWidget() {
        var layout = BlazeStoriesWidgetGridView.twoColumnGridLayout()
        storiesGridWidgetView = BlazeStoriesWidgetGridView(layout: layout)
        storiesGridWidgetView?.widgetDelegate = self
        storiesGridWidgetView?.embedInView(viewToEmbedGridView)
        storiesGridWidgetView?.dataSourceType = .labels(.singleLabel(BlazeSDKInteractor.shared.storiesGridWidgetLabel), maxItems: 6)
        storiesGridWidgetView?.widgetIdentifier = "Top Stories widget"
        storiesGridWidgetView?.adjustSizeAutomatically = true
        storiesGridWidgetView?.reloadData(progressType: .skeleton)
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

extension HomeViewController: BlazeWidgetDelegate {
    
    func onDataLoadStarted(playerType: BlazePlayerType, sourceId: String?) {
        print("onWidgetDataLoadStarted delegate, widgetId: \(sourceId ?? "No source id provided")")
    }
    
    func onDataLoadComplete(playerType: BlazePlayerType, sourceId: String?, itemsCount: Int, result: BlazeResult) {
        refreshControl.endRefreshing()
        switch result {
        case .success():  print("onWidgetDataLoadComplete delegate, widgetId: \(sourceId ?? "No source id provided"), number of items: \(itemsCount)")
        case .failure(let error): print("onWidgetDataLoadComplete with error delegate, widgetId: \(sourceId ?? "No source id provided"), error: \(error.errorMessage)")
        }
    }
    
    func onPlayerDidDismiss(playerType: BlazePlayerType, sourceId: String?) {
        print("onWidgetPlayerDismissed delegate, widgetId: \(sourceId ?? "No source id provided")")
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
}
