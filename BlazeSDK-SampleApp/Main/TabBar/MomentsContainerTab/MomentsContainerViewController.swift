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
    
    private lazy var containerDelegate = createBlazeContainerDelegate()
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
        
        var momentsPlayerStyle = BlazeMomentsPlayerStyle.base()
        
        momentsPlayerStyle.playerDisplayMode = .resizeAspectFillCenterCrop
 
        momentsPlayerStyle.buttons.exit.isVisible = false
        momentsPlayerStyle.buttons.exit.isVisibleForAds = false
        
        momentsPlayerStyle.seekBar.playingState.cornerRadius = 0
        momentsPlayerStyle.seekBar.pausedState.cornerRadius = 0
        momentsPlayerStyle.seekBar.pausedState.isThumbVisible = false
        momentsPlayerStyle.seekBar.bottomSpacing = 0
        momentsPlayerStyle.seekBar.horizontalSpacing = 0
        
        momentsPlayerStyle.cta.horizontalAlignment = .leading
        momentsPlayerStyle.cta.layoutPositioning = .ctaNextToBottomButtonsBox
        momentsPlayerStyle.cta.height = 32
        momentsPlayerStyle.cta.cornerRadius = 16
        momentsPlayerStyle.cta.font = .systemFont(ofSize: 14, weight: .medium)
        momentsPlayerStyle.cta.icon = UIImage(named: "play_icon")
        
        momentsPlayerStyle.headingText.contentSource = .subtitle
        momentsPlayerStyle.headingText.font = .systemFont(ofSize: 14, weight: .light)
        momentsPlayerStyle.headingText.textColor = .white
        
        momentsPlayerStyle.bodyText.contentSource = .description
        momentsPlayerStyle.bodyText.font = .systemFont(ofSize: 16, weight: .bold)
        
        BlazeSDKInteractor.shared.generateMomentsTab(containerId: Constants.tabId,
                                                     dataSourceType: dataSourceType,
                                                     momentsPlayerStyle: momentsPlayerStyle,
                                                     delegate: createBlazeContainerDelegate())
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

    private func createBlazeContainerDelegate() -> BlazePlayerContainerDelegate {
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
                                     actionType: params.actionType,
                                     actionParam: params.actionParam)
        }
    }
}

// MARK: - Moments Container Delegate Handlers

extension MomentsContainerViewController {
    
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
