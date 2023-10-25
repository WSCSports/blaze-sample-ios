//
//  SwiftUIHomeView.swift
//  BlazeSDK-SampleApp
//
//  Created by Dor Zafrir on 24/10/2023.
//

import SwiftUI
import BlazeSDK

// MARK: - SwiftUIHomeView
struct SwiftUIHomeView: View {
    
    @ObservedObject private var viewModel: HomeViewModel
    
    init() {
        self.viewModel = HomeViewModel()
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 12) {
                
                Text("Recent Stories")
                    .font(.system(size: 20, weight: .bold))
                    .padding([.top, .leading])
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                BlazeSwiftUIStoriesRowWidgetView(viewModel: viewModel.storiesRowViewModel)
                .aspectRatio(16.0/9, contentMode: .fit)
                .padding()
                
                HStack(alignment: .center, spacing: 12) {
                    Text("Top Stories")
                        .font(.system(size: 20, weight: .bold))
                        .padding([.leading])
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding([.top, .bottom])
                
                BlazeSwiftUIMomentsRowWidgetView(viewModel: viewModel.momentsRowViewModel)
                    .frame(height: 300)
                
                HStack(alignment: .center, spacing: 12) {
                    Text("Top Stories")
                        .font(.system(size: 20, weight: .bold))
                        .padding([.leading])
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding([.top])
                
                BlazeSwiftUIStoriesGridWidgetView(viewModel: viewModel.storiesGridViewModel)
            }
        }
        .onFirstAppear {
            viewModel.reloadData(progressType: .skeleton)
        }
        .refreshable {
            viewModel.reloadData(progressType: .skeleton)
        }
    }
}


struct SwiftUIHomeViewPewview: PreviewProvider {
    static var previews: some View {
        SwiftUIHomeView()
    }
}


public extension View {
    func onFirstAppear(_ action: @escaping () -> ()) -> some View {
        modifier(FirstAppear(action: action))
    }
}

private struct FirstAppear: ViewModifier {
    let action: () -> ()
    
    @State private var hasAppeared = false
    
    func body(content: Content) -> some View {
        content.onAppear {
            guard !hasAppeared else { return }
            hasAppeared = true
            action()
        }
    }
}

