//
//  Models.swift
//  Squirrel
//
//  Created by A. Zheng (github.com/aheze) on 1/31/23.
//  Copyright © 2023 A. Zheng. All rights reserved.
//

import SwiftUI

/// Stores information about the current scrolling session.
struct ScrollInteraction {
    /// Where the cursor started. Once scrolling/dragging is done, snap back to this position.
    var initialPoint: CGPoint

    /// The target scroll offset.
    var targetDelta: CGFloat

    /// How much delta to scroll by every step.
    var deltaPerStep: CGFloat

    /// How much delta has been scrolled/dragged so far.
    var deltaCompleted = CGFloat(0)

    /// Determines if the scroll interaction should finish.
    var deltaCompletedHasReachedTarget: Bool {
        /// If both 0, return false.
        guard !(deltaCompleted == 0 && targetDelta == 0) else { return false }

        /// Use 0.05 as a threshold in case the floating-point accuracy is lost.
        return abs(deltaCompleted - targetDelta) < 0.05
    }
}
