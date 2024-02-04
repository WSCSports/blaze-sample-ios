//
//  MomentsContainerViewController.swift
//  BlazeSDK-SampleApp
//
//  Created by Dor Zafrir on 09/10/2023.
//

import UIKit
import BlazeSDK
import Combine

class MomentsContainerViewController: UIViewController {
    
    @IBOutlet weak var viewLoader: UIActivityIndicatorView!
    @IBOutlet weak var lblEmptyState: UILabel!
    
    private var loadingState: CurrentValueSubject<Bool, Never> = .init(false)
    private var emptyState: CurrentValueSubject<Bool, Never> = .init(false)
    
    private var subscriptions = Set<AnyCancellable>()
    
    struct Constants {
        static let tabId = "MomentsContainerTab"
    }
        
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupMomentsTab()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        addSubscriptions()
        playMoments()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    private func setupMomentsTab() {
        let dataSourceType: BlazeDataSourceType = .labels(.singleLabel(BlazeSDKInteractor.shared.momentsContainerTabLabel))
        var appearance = BlazeMomentsAppearance()
        appearance.buttons.exit.isVisible = false
        appearance.buttons.exit.isVisibleForAds = false
        appearance.buttons.mute.isVisible = false
        appearance.buttons.mute.isVisibleForAds = false
        appearance.seekBarStyle.isVisible = false
        appearance.headerGradient.isVisible = false
        BlazeSDKInteractor.shared.generateMomentsTab(containerId: Constants.tabId, dataSourceType: dataSourceType, momentsAppearance: appearance, delegate: self)
    }
    
    private func playMoments() {
        BlazeSDKInteractor.shared.playMomentsInContainer(containerId: Constants.tabId, containerVC: self)
    }
    
    private func addSubscriptions() {
        addLoadingStateSubscription()
        addEmptyStateSubscription()
    }
    
    private func addLoadingStateSubscription() {
        loadingState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                self?.handleLoadingState(isLoading: isLoading)
            }
            .store(in: &subscriptions)
    }
    
    private func handleLoadingState(isLoading: Bool) {
        isLoading ? startLoading() : endLoading()
    }
    
    private func startLoading() {
        viewLoader.startAnimating()
        viewLoader.isHidden = false
    }
    
    private func endLoading() {
        viewLoader.stopAnimating()
        viewLoader.isHidden = true
    }
    
    private func addEmptyStateSubscription() {
        emptyState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isEmpty in
                self?.handleEmptyState(isEmpty: isEmpty)
            }
            .store(in: &subscriptions)
    }
    
    private func handleEmptyState(isEmpty: Bool) {
        lblEmptyState.isHidden = !isEmpty
    }

    
}

extension MomentsContainerViewController: BlazePlayerContainerDelegate {
    
    func onDataLoadStarted(playerType: BlazePlayerType, sourceId: String?) {
        loadingState.send(true)
        print("onDataLoadStarted delegate, containerId: \(sourceId ?? "No source id provided")")
    }
    
    func onDataLoadComplete(playerType: BlazePlayerType, sourceId: String?, itemsCount: Int, result: BlazeResult) {
        loadingState.send(false)
        emptyState.send(itemsCount == 0)
        switch result {
        case .success():
            print("onDataLoadComplete delegate, containerId: \(sourceId ?? "No source id provided"), number of items: \(itemsCount)")
        case .failure(let error): print("onDataLoadComplete with error delegate, containerId: \(sourceId ?? "No source id provided"), error: \(error.errorMessage)")
        }
    }
    
    func onPlayerDidDismiss(playerType: BlazePlayerType, sourceId: String?) {
        print("onContainedPlayerDismissed delegate, containerId: \(sourceId ?? "No source id provided")")
    }
    
    func onPlayerDidAppear(playerType: BlazePlayerType, sourceId: String?) {
        print("onContainedPlayerDidAppear delegate, containerId: \(sourceId ?? "No source id provided")")
    }
    
    func onTriggerCTA(playerType: BlazePlayerType, sourceId: String?, actionType: String, actionParam: String) -> Bool {
        return false
    }

}
