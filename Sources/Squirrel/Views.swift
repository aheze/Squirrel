//
//  Views.swift
//  Squirrel
//
//  Created by A. Zheng (github.com/aheze) on 2/1/23.
//  Copyright © 2023 A. Zheng. All rights reserved.
//
    
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

//extension Blur: KeyPathEditable {
//    func effectBlending(_ blending: NSVisualEffectView.BlendingMode) -> Self {
//        var copy = self
//        copy.blending = blending
//        return copy
//    }
//
//    func effectStyle(_ style: NSVisualEffectView.Material) -> Self {
//        var copy = self
//        copy.style = style
//        return copy
//    }
//}
