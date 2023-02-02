//
//  ContentView.swift
//  Squirrel
//
//  Created by A. Zheng (github.com/aheze) on 1/31/23.
//  Copyright © 2023 A. Zheng. All rights reserved.
//

import Combine
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

            VStack(alignment: .leading, spacing: 4.5) {
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

                DoubleFieldRow(viewModel: viewModel, title: "Pointer Size", value: $viewModel.pointerLength)
                DoubleFieldRow(viewModel: viewModel, title: "Pointer Opacity", value: $viewModel.pointerOpacity)
            }

            VStack(alignment: .leading, spacing: 4.5) {
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
                    IntFieldRow(viewModel: viewModel, title: "Scroll Steps", value: $viewModel.numberOfScrollSteps)
                    DoubleFieldRow(viewModel: viewModel, title: "Inactivity Timeout", value: $viewModel.scrollInactivityTimeout)
                    DoubleFieldRow(viewModel: viewModel, title: "Scroll Interval", value: $viewModel.scrollInterval)

                    DoubleFieldRow(viewModel: viewModel, title: "Top Inset", value: $viewModel.deviceBezelInsetTop)
                    DoubleFieldRow(viewModel: viewModel, title: "Left Inset", value: $viewModel.deviceBezelInsetLeft)
                    DoubleFieldRow(viewModel: viewModel, title: "Right Inset", value: $viewModel.deviceBezelInsetRight)
                    DoubleFieldRow(viewModel: viewModel, title: "Bottom Inset", value: $viewModel.deviceBezelInsetBottom)

                    Button {
                        viewModel.resetPreferences()
                    } label: {
                        HStack(spacing: 6) {
                            Text("Reset Preferences")

                            Image(systemName: "arrow.counterclockwise")
                        }
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .font(.footnote.bold())
                        .foregroundColor(NSColor.secondaryLabelColor.color)
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 4)
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
        .onReceive(viewModel.redrawPreferences) { _ in
            color = NSColor(hex: viewModel.pointerColor).color
        }
    }
}

struct DoubleFieldRow: View {
    @ObservedObject var viewModel: ViewModel
    var title: String
    @Binding var value: Double

    var body: some View {
        HStack {
            Text(title)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 8)

            DoubleField(redrawPreferences: viewModel.redrawPreferences, value: $value)
        }
        .menuBackground()
    }
}

struct IntFieldRow: View {
    @ObservedObject var viewModel: ViewModel
    var title: String
    @Binding var value: Int

    var body: some View {
        HStack {
            Text(title)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 8)

            IntField(redrawPreferences: viewModel.redrawPreferences, value: $value)
        }
        .menuBackground()
    }
}

struct DoubleField: View {
    var redrawPreferences: PassthroughSubject<Void, Never>
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
            .onReceive(redrawPreferences) { _ in
                text = "\(value)"
                focused = false
            }
    }
}

struct IntField: View {
    var redrawPreferences: PassthroughSubject<Void, Never>
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
            .onReceive(redrawPreferences) { _ in
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
            .background(Color.black.opacity(0.06))
            .cornerRadius(6)
    }
}
