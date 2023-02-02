//
//  Views.swift
//  Squirrel
//
//  Created by A. Zheng (github.com/aheze) on 2/1/23.
//  Copyright © 2023 A. Zheng. All rights reserved.
//

import Combine
import SwiftUI

struct BlurView: NSViewRepresentable {
    fileprivate var blending: NSVisualEffectView.BlendingMode
    fileprivate var style: NSVisualEffectView.Material

    init(
        blending: NSVisualEffectView.BlendingMode = .behindWindow,
        style: NSVisualEffectView.Material = .fullScreenUI
    ) {
        self.blending = blending
        self.style = style
    }

    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.blendingMode = blending
        view.material = style
        view.state = .followsWindowActiveState
        return view
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.blendingMode = blending
        nsView.material = style
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

// MARK: - Views for setting preferences

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

struct PathFieldRow: View {
    @ObservedObject var viewModel: ViewModel
    var title: String
    @Binding var value: String

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 8)

            PathField(redrawPreferences: viewModel.redrawPreferences, value: $value)
                .offset(y: -8)
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

struct PathField: View {
    var redrawPreferences: PassthroughSubject<Void, Never>
    @Binding var value: String
    @State var text: String = ""
    @FocusState var focused: Bool

    var body: some View {
        TextField("Integer", text: $text)
            .multilineTextAlignment(.leading)
            .focused($focused)
            .focusable(false)
            .onSubmit {
                if FileManager.default.fileExists(atPath: text) {
                    value = text
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
