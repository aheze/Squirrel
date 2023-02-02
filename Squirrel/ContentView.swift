//
//  ContentView.swift
//  Squirrel
//
//  Created by A. Zheng (github.com/aheze) on 1/31/23.
//  Copyright © 2023 A. Zheng. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel: ViewModel
    @State var color = NSColor(hex: 0x007EEF).color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Squirrel")
                .font(.title3)
                .fontWeight(.bold)

            VStack(alignment: .leading, spacing: 4) {
                MenuToggleRow(title: "Enabled", isOn: $viewModel.enabled)
                MenuToggleRow(title: "Natural Scrolling", isOn: $viewModel.naturalScrolling)

                HStack {
                    Text("Color")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 8)

                    ColorPicker("Color", selection: $color)
                        .labelsHidden()
                }
                .menuBackground()
            }
        }
        .frame(width: 200, alignment: .topLeading)
        .padding(12)
        .onAppear {
            color = NSColor(hex: viewModel.color).color
        }
        .onChange(of: color) { newValue in
            viewModel.color = NSColor(newValue).hex
        }
    }
}

struct MenuToggleRow: View {
    var title: String
    @Binding var isOn: Bool

    var body: some View {
        HStack {
            Text(title)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 8)

            Toggle(title, isOn: $isOn)
                .labelsHidden()
        }
        .menuBackground()
        .onTapGesture {
            isOn.toggle()
        }
    }
}

extension View {
    func menuBackground() -> some View {
        padding(.horizontal, 12)
            .background(Color.black.opacity(0.08))
            .cornerRadius(6)
            .contentShape(Rectangle())
    }
}
