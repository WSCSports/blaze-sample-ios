//
//  MomentsViewController.swift
//  BlazeSDK-SampleApp
//
//  Created by Dor Zafrir on 17/08/2023.
//

import UIKit
import BlazeSDK

class MomentsViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var viewToEmbedRowView: UIView!
    @IBOutlet weak var viewToEmbedGridView: UIView!
    
    private var momentsWidgetRowView: BlazeMomentsWidgetRowView?
    private var momentsWidgetGridView: BlazeMomentsWidgetGridView?
    
    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(pullToRefreshTriggered), for: .valueChanged)
        return refreshControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMomentsRowWidget()
        setupMomentsGridWidget()
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
    
    private func setupMomentsRowWidget() {
        var layout = BlazeMomentsWidgetRowView.rectangleLayout()
        layout.maxDisplayItemsCount = 6
        momentsWidgetRowView = BlazeMomentsWidgetRowView(layout: layout)
        momentsWidgetRowView?.widgetDelegate = self
        momentsWidgetRowView?.embedInView(viewToEmbedRowView)
        momentsWidgetRowView?.dataSourceType = .labels(.singleLabel(BlazeSDKInteractor.shared.momentsRowWidgetLabel))
        momentsWidgetRowView?.widgetIdentifier = "Moments Row Widget"
        momentsWidgetRowView?.reloadData(progressType: .skeleton)
    }
    
    private func setupMomentsGridWidget() {
        let layout = BlazeMomentsWidgetGridView.twoColumnGridLayout()
        momentsWidgetGridView = BlazeMomentsWidgetGridView(layout: layout)
        momentsWidgetGridView?.widgetDelegate = self
        momentsWidgetGridView?.adjustSizeAutomatically = true
        momentsWidgetGridView?.embedInView(viewToEmbedGridView)
        momentsWidgetGridView?.dataSourceType = .labels(.singleLabel(BlazeSDKInteractor.shared.momentsGridWidgetLabel))
        momentsWidgetGridView?.widgetIdentifier = "Moments Grid Widget"
        momentsWidgetGridView?.refreshControl = refreshControl
        momentsWidgetGridView?.reloadData(progressType: .skeleton)
    }
    
    private func handleDeepLink(action: String) {
        BlazeSDKInteractor.shared.dismissCurrentPlayer()
        print("handle deep link")
    }
    
    @objc func pullToRefreshTriggered(refreshControl: UIRefreshControl) {
        momentsWidgetRowView?.reloadData(progressType: .silent)
        momentsWidgetGridView?.reloadData(progressType: .silent)
    }
    
}

extension MomentsViewController: BlazeWidgetDelegate {
    func onWidgetDataLoadComplete(widgetId: String, itemsCount: Int, result: BlazeResult) {
        refreshControl.endRefreshing()
        switch result {
        case .success():  print("onWidgetDataLoadComplete delegate, widgetId: \(widgetId), number of items: \(itemsCount)")
        case .failure(let error): print("onWidgetDataLoadComplete with error delegate, widgetId: \(widgetId), error: \(error.errorMessage)")
        }
    }
    
    func onWidgetDataLoadStarted(widgetId: String) {
        print("onWidgetDataLoadStarted delegate, widgetId: \(widgetId)")
    }

    func onWidgetPlayerDismissed(widgetId: String) {
        print("onWidgetPlayerDismissed delegate, widgetId: \(widgetId)")
    }

    func onTriggerCTA(widgetId: String, actionType: String, actionParam: String) -> Bool {
        print("onTriggerCTA delegate, widgetId: \(widgetId), actionType =\(actionType), actionParam: \(actionParam)")
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
