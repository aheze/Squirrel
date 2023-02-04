//
//  ContentView.swift
//  Squirrel
//
//  Created by A. Zheng (github.com/aheze) on 1/31/23.
//  Copyright © 2023 A. Zheng. All rights reserved.
//

import Combine
import SwiftUI

/// The popover menu that's shown when you press the menu bar button.
struct ContentView: View {
    @ObservedObject var viewModel: ViewModel

    /// Keep a local storage of the pointer color for more stable color picking.
    @State var pointerColor = NSColor(hex: 0x007EEF).color

    /// Keeps track of whether the advanced section is shown.
    @State var showingAdvanced = false

    /// Keeps track of whether the "about" section is shown.
    @State var showingAbout = false

    /// The total height of the main content inside the menu.
    @State var contentHeight = Preferences.menuMaximumHeight

    /// Animation flag for the app icon wheel.
    @State var animatingSpin = false

    /// Extra angle added when the app icon is tapped.
    @State var animatingSpinExtraAngle = CGFloat(0)

    var body: some View {
        /// Prevent the content from surpassing `menuMaximumHeight`.
        let height: CGFloat = {
            if contentHeight < viewModel.menuMaximumHeight {
                return contentHeight
            } else {
                return viewModel.menuMaximumHeight
            }
        }()

        ScrollView {
            content
                .padding(12)
                .readSize { size in
                    contentHeight = size.height
                }
        }
        .frame(width: viewModel.menuWidth, height: height, alignment: .topLeading)
        .onAppear {
            pointerColor = NSColor(hex: viewModel.pointerColor).color
        }
        .onChange(of: pointerColor) { newValue in
            viewModel.pointerColor = NSColor(newValue).hex
        }
        .onReceive(viewModel.redrawPreferences) { _ in
            pointerColor = NSColor(hex: viewModel.pointerColor).color
        }
    }

    /// The main content inside the menu.
    var content: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Squirrel")
                    .font(.title3)
                    .fontWeight(.bold)

                Spacer()

                HStack(spacing: 8) {
                    SocialButton(image: "Twitter", url: "https://twitter.com/aheze0")
                    SocialButton(image: "GitHub", url: "https://github.com/aheze/Squirrel")

                    Button {
                        showingAbout.toggle()
                    } label: {
                        Image(systemName: "info.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(NSColor.labelColor.color)
                            .opacity(0.5)
                    }
                    .buttonStyle(.plain)
                    .frame(width: 17, height: 17)
                    .padding(.leading, 2)
                }
            }

            if showingAbout {
                aboutView
            }

            /// Show a header when permissions aren't granted yet.
            if !viewModel.permissionsGranted {
                VStack(alignment: .leading, spacing: 0) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Accessibility Permissions Needed")
                            .foregroundColor(.white)
                            .font(.title3)
                            .fontWeight(.semibold)

                        Text("Tap to open Accessibility settings")
                            .foregroundColor(.white.opacity(0.7))
                            .font(.body)
                            .fontWeight(.medium)
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.blue.brightness(-0.2))

                    VStack(alignment: .leading, spacing: 8) {
                        StepView(number: "1", title: "Settings")
                        StepView(number: "2", title: "Privacy & Security")
                        StepView(number: "3", title: "Accessibility")
                        StepView(number: "4", title: "Turn on for Squirrel")
                    }
                    .foregroundColor(.blue)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(12)
                    .background(Color.blue.opacity(0.08))
                }
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
                .cornerRadius(6)
                .contentShape(Rectangle())
                .onTapGesture {
                    if let accessibilityUrl = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
                        NSWorkspace.shared.open(accessibilityUrl)
                    }
                }
            }

            VStack(alignment: .leading, spacing: 4.5) {
                MenuToggleRow(title: "Enabled", isOn: $viewModel.enabled)
                MenuToggleRow(title: "Natural Scrolling", isOn: $viewModel.naturalScrolling)

                HStack {
                    Text("Pointer Color")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 8)

                    ColorPicker("Pointer Color", selection: $pointerColor)
                        .labelsHidden()
                }
                .menuBackground()

                DoubleFieldRow(viewModel: viewModel, title: "Pointer Size", value: $viewModel.pointerLength)
                DoubleFieldRow(viewModel: viewModel, title: "Pointer Opacity", value: $viewModel.pointerOpacity)
                DoubleFieldRow(viewModel: viewModel, title: "Pointer Scale", value: $viewModel.pointerScaleRatio)
            }

            VStack(alignment: .leading, spacing: 4.5) {
                HStack(spacing: 16) {
                    Button {
                        viewModel.quitApplication()
                    } label: {
                        Text("Quit")
                    }
                    .buttonStyle(.plain)

                    Spacer()

                    Button {
                        showingAdvanced.toggle()
                    } label: {
                        HStack(spacing: 3) {
                            Text("Advanced")

                            Image(systemName: "chevron.right")
                                .rotationEffect(.degrees(showingAdvanced ? 90 : 0))
                        }
                    }
                    .buttonStyle(.plain)
                }
                .font(.footnote.bold())
                .foregroundColor(NSColor.secondaryLabelColor.color)

                if showingAdvanced {
                    advancedView
                }
            }
        }
    }

    var advancedView: some View {
        VStack(alignment: .leading, spacing: 4.5) {
            Group {
                MenuToggleRow(title: "Launch Simulator On Startup", isOn: Binding {
                    viewModel.launchSimulatorOnStartup
                } set: { newValue in
                    viewModel.launchSimulatorOnStartup = newValue
                    if newValue == false {
                        viewModel.quitIfSimulatorClosed = false
                    }
                })

                MenuToggleRow(title: "Quit If Simulator Is Closed", isOn: $viewModel.quitIfSimulatorClosed)
                    .disabled(viewModel.launchSimulatorOnStartup == false)
            }

            Group {
                IntFieldRow(viewModel: viewModel, title: "Scroll Steps", value: $viewModel.numberOfScrollSteps)
                DoubleFieldRow(viewModel: viewModel, title: "Inactivity Timeout", value: $viewModel.scrollInactivityTimeout)
                DoubleFieldRow(viewModel: viewModel, title: "Scroll Interval", value: $viewModel.scrollInterval)
            }

            Group {
                DoubleFieldRow(viewModel: viewModel, title: "Top Inset", value: $viewModel.deviceBezelInsetTop)
                DoubleFieldRow(viewModel: viewModel, title: "Left Inset", value: $viewModel.deviceBezelInsetLeft)
                DoubleFieldRow(viewModel: viewModel, title: "Right Inset", value: $viewModel.deviceBezelInsetRight)
                DoubleFieldRow(viewModel: viewModel, title: "Bottom Inset", value: $viewModel.deviceBezelInsetBottom)
                PathFieldRow(viewModel: viewModel, title: "Simulator Location", value: $viewModel.simulatorPath)
                DoubleFieldRow(viewModel: viewModel, title: "Simulator Check Frequency", value: $viewModel.simulatorCheckFrequency)
            }

            Group {
                DoubleFieldRow(viewModel: viewModel, title: "Max Height", value: $viewModel.menuMaximumHeight)
                DoubleFieldRow(viewModel: viewModel, title: "Menu Width", value: $viewModel.menuWidth)
            }

            Button {
                viewModel.resetPreferences()
            } label: {
                HStack(spacing: 6) {
                    Text("Reset Preferences")

                    Image(systemName: "arrow.counterclockwise")
                }
                .foregroundColor(NSColor.secondaryLabelColor.color)
                .font(.footnote.bold())
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .buttonStyle(.plain)
            .padding(.top, 4)
        }
    }

    var aboutView: some View {
        VStack {
            Image("AppIcon-Base")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 160, height: 160)
                .overlay(
                    Image("AppIcon-Wheel")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .shadow(color: .black.opacity(0.75), radius: 6, x: 0, y: 0)
                        .frame(width: 62, height: 62)
                        .rotationEffect(.degrees(animatingSpin ? 360 : 0))
                        .rotationEffect(.degrees(animatingSpinExtraAngle))
                        .offset(y: 3)
                )
                .onTapGesture {
                    withAnimation(.spring(response: 1.2, dampingFraction: 1, blendDuration: 1)) {
                        animatingSpinExtraAngle += 90
                    }
                }

            Text("Squirrel made by [aheze](https://twitter.com/aheze0)")
                .foregroundColor(NSColor.secondaryLabelColor.color)
                .fontWeight(.semibold)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 16)
        .padding(.bottom, 20)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.linear(duration: 6).repeatForever(autoreverses: false)) {
                    animatingSpin = true
                }
            }
        }
        .onDisappear {
            animatingSpin = false
        }
    }
}
