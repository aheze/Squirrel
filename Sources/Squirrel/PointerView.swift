//
//  PointerView.swift
//  Squirrel
//
//  Created by A. Zheng (github.com/aheze) on 1/31/23.
//  Copyright © 2023 A. Zheng. All rights reserved.
//

import SwiftUI

struct PointerView: View {
    @ObservedObject var viewModel: ViewModel
    @State var visible = false

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            NSColor(hex: viewModel.pointerColor).color,
                            NSColor(hex: viewModel.pointerColor).offset(by: 0.1).color
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .opacity((viewModel.scrollInteraction != nil) ? viewModel.pointerOpacity : 0)
        }
        .frame(width: viewModel.pointerLength, height: viewModel.pointerLength)
        .frame(width: viewModel.pointerWindowLength, height: viewModel.pointerWindowLength)
        .scaleEffect((viewModel.scrollInteraction != nil) ? 1 : viewModel.pointerScaleRatio)
        .animation(.spring(response: 0.25, dampingFraction: 1, blendDuration: 1), value: viewModel.scrollInteraction != nil)
    }
}
