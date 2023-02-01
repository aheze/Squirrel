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
        Circle()
            .fill(Color.purple)
            .frame(width: viewModel.pointerLength, height: viewModel.pointerLength)
            .opacity(0.75)
            .opacity((viewModel.scrollInteraction != nil) ? 1 : 0)
            .animation(.linear(duration: 0.5), value: viewModel.scrollInteraction != nil)
//            .onAppear {
//                withAnimation(.linear(duration: 0.5).repeatForever()) {
//                    visible.toggle()
//                }
//            }
    }
}
