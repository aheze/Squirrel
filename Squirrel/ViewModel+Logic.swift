//
//  ViewModel+Logic.swift
//  Squirrel
//
//  Created by A. Zheng (github.com/aheze) on 1/31/23.
//  Copyright © 2023 A. Zheng. All rights reserved.
//

import Carbon.HIToolbox
import Cocoa

extension ViewModel {
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

    func stopScroll() {
        timer?.invalidate()
        timer = nil

        if let scrollInteraction {
            self.scrollInteraction = nil

            let endPoint = CGPoint(
                x: scrollInteraction.initialPoint.x,
                y: scrollInteraction.initialPoint.y + scrollInteraction.deltaCompleted
            )

            let mouseUp = CGEvent(mouseEventSource: nil, mouseType: .leftMouseUp, mouseCursorPosition: endPoint, mouseButton: .left)
            mouseUp?.post(tap: .cghidEventTap)

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.005) {
                CGWarpMouseCursorPosition(scrollInteraction.initialPoint)
            }
        }
    }

    func processScroll(event: NSEvent) {
        if !allowMomentumScroll {
            if event.momentumPhase == .changed {
                return
            }
        }
        if event.momentumPhase == .ended {
            allowMomentumScroll = true
        }

        guard enabled else {
            stopScroll()
            return
        }

        scrollEventActivityCounter.send()

        /// `NSEvent.mouseLocation` seems to be more accurate than `event.locationInWindow`
        let point = convertPointToScreen(point: NSEvent.mouseLocation)

        let frames = getSimulatorWindowFrames()

        let shouldContinue: Bool = {
            let intersectingFrame = frames.first(where: { $0.contains(point) })

            if let intersectingFrame {
                guard let screen = getScreenWithMouse() else {
                    return false
                }

                let screenHeightToWidthRatio = screen.frame.height / screen.frame.width
                let simulatorHeightToWidthRatio = intersectingFrame.height / intersectingFrame.width

                /// if the ratios match, the simulator is in full screen mode.
                if simulatorHeightToWidthRatio > screenHeightToWidthRatio {
                    var insetFrame = intersectingFrame
                    insetFrame.origin.x += deviceBezelInset.leading
                    insetFrame.origin.y += deviceBezelInset.top
                    insetFrame.size.width -= deviceBezelInset.leading + deviceBezelInset.trailing
                    insetFrame.size.height -= deviceBezelInset.top + deviceBezelInset.bottom

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

        guard shouldContinue else {
            if let scrollInteraction {
                /// Stop further momentum scroll events from triggering.
                allowMomentumScroll = false

                CGWarpMouseCursorPosition(scrollInteraction.initialPoint)
            }

            return
        }

        let delta: CGFloat = {
            if naturalScrolling {
                return event.scrollingDeltaY
            } else {
                return event.scrollingDeltaY * -1
            }
        }()

        if var scrollInteraction {
            scrollInteraction.targetDelta += delta

            let deltaPerStep = (scrollInteraction.targetDelta - scrollInteraction.deltaCompleted) / CGFloat(iterationsCount)
            scrollInteraction.deltaPerStep = deltaPerStep

            self.scrollInteraction = scrollInteraction

        } else {
            let deltaPerStep = delta / CGFloat(iterationsCount)
            let scrollInteraction = ScrollInteraction(
                initialPoint: point,
                targetDelta: delta,
                deltaPerStep: deltaPerStep
            )
            self.scrollInteraction = scrollInteraction

            let mouseDown = CGEvent(mouseEventSource: nil, mouseType: .leftMouseDown, mouseCursorPosition: point, mouseButton: .left)
            mouseDown?.post(tap: .cghidEventTap)

            timer = Timer.scheduledTimer(withTimeInterval: scrollFrequency, repeats: true) { [weak self] _ in
                guard let self = self else { return }
                guard let scrollInteraction = self.scrollInteraction else { return }
                guard !scrollInteraction.isComplete else {
                    self.stopScroll()
                    return
                }

                let targetPoint = CGPoint(
                    x: scrollInteraction.initialPoint.x,
                    y: scrollInteraction.initialPoint.y + scrollInteraction.deltaCompleted + scrollInteraction.deltaPerStep
                )
                let mouseDrag = CGEvent(mouseEventSource: nil, mouseType: .leftMouseDragged, mouseCursorPosition: targetPoint, mouseButton: .left)
                mouseDrag?.post(tap: .cghidEventTap)

                self.scrollInteraction?.deltaCompleted += scrollInteraction.deltaPerStep
            }
        }
    }
}
