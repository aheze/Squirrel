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
        /// if both 0, return false
        guard !(deltaCompleted == 0 && targetDelta == 0) else { return false }
        
        /// Use 0.05 as a threshold in case the floating-point accuracy is lost
        return abs(deltaCompleted - targetDelta) < 0.05
    }
}
