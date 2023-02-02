//
//  Utilities.swift
//  Squirrel
//
//  Created by A. Zheng (github.com/aheze) on 2/1/23.
//  Copyright © 2023 A. Zheng. All rights reserved.
//

import SwiftUI

extension NSColor {
    convenience init(hex: Int, alpha: CGFloat = 1) {
        self.init(hex: UInt(hex), alpha: alpha)
    }

    convenience init(hex: UInt, alpha: CGFloat = 1) {
        self.init(
            red: CGFloat((hex & 0xFF0000) >> 16) / 255,
            green: CGFloat((hex & 0x00FF00) >> 8) / 255,
            blue: CGFloat(hex & 0x0000FF) / 255,
            alpha: alpha
        )
    }

    var hsba: (h: CGFloat, s: CGFloat, b: CGFloat, a: CGFloat) {
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        self.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        return (h: h, s: s, b: b, a: a)
    }

    var hex: Int {
        return getHex() ?? 0x00AEEF
    }

    var hexString: String {
        return String(hex, radix: 16, uppercase: true)
    }

    /// from https://stackoverflow.com/a/28645384/14351818
    func getHex() -> Int? {
        var fRed: CGFloat = 0
        var fGreen: CGFloat = 0
        var fBlue: CGFloat = 0
        var fAlpha: CGFloat = 0

        getRed(&fRed, green: &fGreen, blue: &fBlue, alpha: &fAlpha)
        /// could be negative
        fRed = fRed.clamped(to: 0 ... 1)
        fGreen = fGreen.clamped(to: 0 ... 1)
        fBlue = fBlue.clamped(to: 0 ... 1)

        let iRed = UInt(fRed * 255.0)
        let iGreen = UInt(fGreen * 255.0)
        let iBlue = UInt(fBlue * 255.0)

        //  (Bits 24-31 are alpha, 16-23 are red, 8-15 are green, 0-7 are blue).
        let hex = (iRed << 16) + (iGreen << 8) + iBlue
        return Int(hex)
    }

    /// get a gradient color
    func offset(by offset: CGFloat) -> NSColor {
        let (h, s, b, a) = hsba
        var newHue = h - offset

        /// make it go back to positive
        while newHue <= 0 {
            newHue += 1
        }
        let normalizedHue = newHue.truncatingRemainder(dividingBy: 1)
        return NSColor(hue: normalizedHue, saturation: s, brightness: b, alpha: a)
    }
}

extension NSColor {
    var color: Color {
        return Color(self)
    }
}

extension Comparable {
    /// used for the UIColor
    func clamped(to limits: ClosedRange<Self>) -> Self {
        return min(max(self, limits.lowerBound), limits.upperBound)
    }
}

public extension View {
    @inlinable
    func reverseMask<Mask: View>(
        padding: CGFloat = 0, /// extra negative padding for shadows
        @ViewBuilder _ mask: () -> Mask
    ) -> some View {
        self.mask(
            Rectangle()
                .padding(-padding)
                .overlay(
                    mask()
                        .blendMode(.destinationOut)
                )
        )
    }
}
