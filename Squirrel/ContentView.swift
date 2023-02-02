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
            HStack {
                Text("Squirrel")
                    .font(.title3)
                    .fontWeight(.bold)

                Spacer()

                HStack(spacing: 8) {
                    SocialButton(image: "Twitter", url: "https://twitter.com/aheze0")
                    SocialButton(image: "GitHub", url: "https://github.com/aheze/Squirrel")
                }
            }

//            viewModel.permissionsGranted
            if true {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Accessibility Permissions Needed")
                        .foregroundColor(.white)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(12)
                        .background(Color.blue.brightness(-0.2))

                    VStack(alignment: .leading, spacing: 8) {
                        StepView(number: "1", title: "Settings")
                        StepView(number: "2", title: "Privacy & Security")
                        StepView(number: "3", title: "Accessibility")
                    }
                    .foregroundColor(.blue)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(12)
                    .background(Color.blue.opacity(0.08))
                }
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
                .cornerRadius(6)
            }

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
                DoubleFieldRow(viewModel: viewModel, title: "Pointer Scale", value: $viewModel.pointerScaleRatio)
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

struct SocialButton: View {
    var image: String
    var url: String

    var body: some View {
        Button {
            if let url = URL(string: url) {
                NSWorkspace.shared.open(url)
            }
        } label: {
            Image(image)
                .renderingMode(.template)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(NSColor.labelColor.color)
                .opacity(0.5)
        }
        .buttonStyle(.plain)
        .frame(width: 19, height: 19)
    }
}

struct StepView: View {
    var number: String
    var title: String

    var body: some View {
        HStack(spacing: 8) {
            Text(number)
                .fontDesign(.rounded)
                .frame(width: 24, height: 24)
                .background {
                    Circle()
                        .fill(.blue)
                        .brightness(-0.2)
                        .opacity(0.08)
                }

            Text(title)
        }
    }
}
