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
    @State var showingAdvanced = false

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

                    DoubleField(value: $viewModel.pointerLength)
                }
                .menuBackground()

                HStack {
                    Text("Pointer Opacity")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 8)

                    DoubleField(value: $viewModel.pointerOpacity)
                }
                .menuBackground()
            }

            VStack(alignment: .leading, spacing: 4) {
                Button {
                    showingAdvanced.toggle()
                } label: {
                    HStack(spacing: 6) {
                        Text("Advanced")

                        Image(systemName: "chevron.right")
                            .rotationEffect(.degrees(showingAdvanced ? 90 : 0))
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .font(.footnote.bold())
                    .foregroundColor(NSColor.secondaryLabelColor.color)
                }
                .buttonStyle(.plain)

                if showingAdvanced {
                    HStack {
                        Text("Scroll Steps")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 8)

                        IntField(value: $viewModel.numberOfScrollSteps)
                    }
                    .menuBackground()

                    HStack {
                        Text("Inactivity Timeout")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 8)

                        DoubleField(value: $viewModel.scrollInactivityTimeout)
                    }
                    .menuBackground()

                    HStack {
                        Text("Scroll Interval")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 8)

                        DoubleField(value: $viewModel.scrollInterval)
                    }
                    .menuBackground()

                    HStack {
                        Text("Top Inset")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 8)

                        DoubleField(value: $viewModel.deviceBezelInsetTop)
                    }
                    .menuBackground()

                    HStack {
                        Text("Left Inset")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 8)

                        DoubleField(value: $viewModel.deviceBezelInsetLeft)
                    }
                    .menuBackground()

                    HStack {
                        Text("Right Inset")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 8)

                        DoubleField(value: $viewModel.deviceBezelInsetRight)
                    }
                    .menuBackground()

                    HStack {
                        Text("Bottom Inset")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 8)

                        DoubleField(value: $viewModel.deviceBezelInsetBottom)
                    }
                    .menuBackground()
                }
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

struct DoubleField: View {
    @Binding var value: Double
    @State var text = ""
    @FocusState var focused: Bool

    var body: some View {
        TextField("Number", text: $text)
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

struct IntField: View {
    @Binding var value: Int
    @State var text = ""
    @FocusState var focused: Bool

    var body: some View {
        TextField("Integer", text: $text)
            .multilineTextAlignment(.trailing)
            .fixedSize(horizontal: true, vertical: false)
            .focused($focused)
            .focusable(false)
            .onSubmit {
                let text = text.trimmingCharacters(in: .whitespacesAndNewlines)
                if let int = Int(text) {
                    value = int
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
    }
}
