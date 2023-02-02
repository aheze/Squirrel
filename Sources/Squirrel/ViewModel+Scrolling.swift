//
//  ViewModel+Scrolling.swift
//  Squirrel
//
//  Created by A. Zheng (github.com/aheze) on 1/31/23.
//  Copyright © 2023 A. Zheng. All rights reserved.
//

import Carbon.HIToolbox
import Cocoa

extension ViewModel {
    /// Listen to the `ESC` key (acts as an emergency stop in case Squirrel bugs out).
    func processKey(event: NSEvent) {
        switch Int(event.keyCode) {
            case kVK_Escape:
                if scrollInteraction != nil {
                    allowMomentumScroll = false
                }
                stopScroll()
            default:
                break
        }
    }

    /// Stop the current scroll interaction.
    func stopScroll() {
        timer?.invalidate()
        timer = nil

        if let scrollInteraction {
            self.scrollInteraction = nil

            if let event = CGEvent(source: nil) {
                let mouseUp = CGEvent(mouseEventSource: nil, mouseType: .leftMouseUp, mouseCursorPosition: event.location, mouseButton: .left)
                mouseUp?.post(tap: .cghidEventTap)

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    let mouseMoved = CGEvent(mouseEventSource: nil, mouseType: .mouseMoved, mouseCursorPosition: scrollInteraction.initialPoint, mouseButton: .left)
                    mouseMoved?.post(tap: .cghidEventTap)
                }
            }
        }
    }

    /// Process a mouse scroll event.
    func processScroll(event: NSEvent) {
        guard enabled else {
            stopScroll()
            return
        }

        /// `NSEvent.mouseLocation` seems to be more accurate than `event.locationInWindow`.
        let point = convertPointToScreen(point: NSEvent.mouseLocation)
        let (simulatorFrames, ignoredFrames) = getSimulatorWindowFrames()

        /// Just in case another window overlaps the simulator.
        guard !ignoredFrames.contains(where: { $0.contains(point) }) else {
            return
        }

        /// Ignore if momentum scroll is not allowed.
        if !allowMomentumScroll, event.momentumPhase == .changed {
            return
        }

        /// However, if the scroll wheel came to a stop, enable momentum scroll later on.
        if event.momentumPhase == .ended {
            allowMomentumScroll = true
        }

        /// Keep scrolling active.
        scrollEventActivityCounter.send()

        /// Determine if the cursor is within the bounds of the simulator.
        let shouldContinue: Bool = {
            let intersectingFrame = simulatorFrames.first(where: { $0.contains(point) })

            if let intersectingFrame {
                guard let screen = getScreenWithMouse() else {
                    return false
                }

                let screenHeightToWidthRatio = screen.frame.height / screen.frame.width
                let simulatorHeightToWidthRatio = intersectingFrame.height / intersectingFrame.width

                /// if the ratios match, the simulator is in full screen mode.
                if simulatorHeightToWidthRatio > screenHeightToWidthRatio {
                    var insetFrame = intersectingFrame
                    insetFrame.origin.x += deviceBezelInsetLeft
                    insetFrame.origin.y += deviceBezelInsetTop
                    insetFrame.size.width -= deviceBezelInsetLeft + deviceBezelInsetRight
                    insetFrame.size.height -= deviceBezelInsetTop + deviceBezelInsetBottom

                    let contains = insetFrame.contains(point)

                    if !contains {
                        return false
                    }
                }

                return true
            } else {
                return false
            }
        }()

        /// If the cursor went outside the allowed bounds, stop scrolling.
        guard shouldContinue else {
            if scrollInteraction != nil {
                /// Stop further momentum scroll events from triggering.
                allowMomentumScroll = false

                /// Quickly scroll to the target value.
                timer?.invalidate()
                timer = Timer.scheduledTimer(withTimeInterval: 0.001, repeats: true) { [weak self] _ in
                    guard let self = self else { return }
                    self.fireTimer()
                }
            }

            return
        }

        /// Get how much to drag the screen by.
        let delta: CGFloat = {
            if naturalScrolling {
                return event.scrollingDeltaY
            } else {
                return event.scrollingDeltaY * -1
            }
        }()

        /// If a scroll interaction already exists, add the delta to the existing one.
        if var scrollInteraction {
            scrollInteraction.targetDelta += delta

            let deltaPerStep = (scrollInteraction.targetDelta - scrollInteraction.deltaCompleted) / CGFloat(numberOfScrollSteps)
            scrollInteraction.deltaPerStep = deltaPerStep

            self.scrollInteraction = scrollInteraction

        } else {
            /**
             Otherwise, create a new scroll interaction.

             Setting `scrollInteraction` will show a pointer where the cursor originally is.
             */
            let deltaPerStep = delta / CGFloat(numberOfScrollSteps)
            let scrollInteraction = ScrollInteraction(
                initialPoint: point,
                targetDelta: delta,
                deltaPerStep: deltaPerStep
            )
            self.scrollInteraction = scrollInteraction

            /// Start by clicking down.
            let mouseDown = CGEvent(mouseEventSource: nil, mouseType: .leftMouseDown, mouseCursorPosition: point, mouseButton: .left)
            mouseDown?.post(tap: .cghidEventTap)

            timer = Timer.scheduledTimer(withTimeInterval: scrollInterval, repeats: true) { [weak self] _ in
                guard let self = self else { return }
                self.fireTimer()
            }
        }
    }

    /// Simulate a drag effect.
    func fireTimer() {
        guard let scrollInteraction = scrollInteraction else { return }
        guard !scrollInteraction.deltaCompletedHasReachedTarget else {
            /// If the scroll interaction has reached the target delta, stop scrolling.
            stopScroll()
            return
        }

        let targetPoint = CGPoint(
            x: scrollInteraction.initialPoint.x,

            /// Drag by `deltaPerStep` each time this method is called.
            y: scrollInteraction.initialPoint.y + scrollInteraction.deltaCompleted + scrollInteraction.deltaPerStep
        )

        let mouseDrag = CGEvent(mouseEventSource: nil, mouseType: .leftMouseDragged, mouseCursorPosition: targetPoint, mouseButton: .left)
        mouseDrag?.post(tap: .cghidEventTap)

        
        /// Add on the delta to the state.
        self.scrollInteraction?.deltaCompleted += scrollInteraction.deltaPerStep
    }
}
