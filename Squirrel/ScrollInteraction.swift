//
//  ScrollInteraction.swift
//  Squirrel
//
//  Created by A. Zheng (github.com/aheze) on 1/31/23.
//  Copyright © 2023 A. Zheng. All rights reserved.
//

import SwiftUI

struct ScrollInteraction {
    var initialPoint: CGPoint
    var targetDelta: CGFloat
    var deltaPerStep: CGFloat
    var deltaCompleted = CGFloat(0)

    var isComplete: Bool {
        /// Use 0.05 as a threshold in case the floating-point accuracy is lost
        return abs(deltaCompleted - targetDelta) < 0.05
    }
}
