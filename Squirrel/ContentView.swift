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
                    Text("Pointer Color")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 8)

                    ColorPicker("Pointer Color", selection: $color)
                        .labelsHidden()
                }
                .menuBackground()

                HStack {
                    Text("Pointer Size")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 8)

                    NumberField(value: $viewModel.pointerLength)
                }
                .menuBackground()

                HStack {
                    Text("Pointer Opacity")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 8)

                    NumberField(value: $viewModel.pointerOpacity)
                }
                .menuBackground()
            }
        }
        .frame(width: 200, alignment: .topLeading)
        .padding(12)
        .onAppear {
            color = NSColor(hex: viewModel.pointerColor).color
        }
        .onChange(of: color) { newValue in
            viewModel.pointerColor = NSColor(newValue).hex
        }
    }
}

struct NumberField: View {
    @Binding var value: Double
    @State var text = ""
    @FocusState var focused: Bool

    var body: some View {
        TextField("Value", text: $text)
            .multilineTextAlignment(.trailing)
            .fixedSize(horizontal: true, vertical: false)
            .focused($focused)
            .focusable(false)
            .onSubmit {
                let text = text.trimmingCharacters(in: .whitespacesAndNewlines)
                if let double = Double(text) {
                    value = double
                } else {
                    self.text = "\(value)"
                }
                focused = false
            }
            .onAppear {
                text = "\(value)"
                focused = false
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
