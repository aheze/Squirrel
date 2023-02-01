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
    
    var body: some View {
        Circle()
            .fill(Color.purple)
            .frame(width: viewModel.pointerLength, height: viewModel.pointerLength)
    }
}
