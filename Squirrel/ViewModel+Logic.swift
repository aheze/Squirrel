//
//  ViewModel+Logic.swift
//  Squirrel
//
//  Created by A. Zheng (github.com/aheze) on 1/31/23.
//  Copyright © 2023 A. Zheng. All rights reserved.
//

import Cocoa

extension ViewModel {
    func processMove(event: NSEvent) {
        if let scrollInteraction {
            let point = getPoint(event: event)

            /// make sure it moved a distance (prevent activating buttons)
            guard abs(point.y - scrollInteraction.initialPoint.y) > scrollCancelDistance else { return }

            stopScroll()
        }
    }

    func stopScroll() {
        timer?.invalidate()
        timer = nil

        if let scrollInteraction {
            let mouseUp = CGEvent(mouseEventSource: nil, mouseType: .leftMouseUp, mouseCursorPosition: scrollInteraction.initialPoint, mouseButton: .left)
            mouseUp?.post(tap: .cghidEventTap)
        }

        scrollInteraction = nil
    }

    func processScroll(event: NSEvent) {
        scrollEventActivityCounter.send()
        let point = getPoint(event: event)

        let frames = getSimulatorWindowFrames()
        let shouldContinue: Bool = {
            let intersectingFrame = frames.first(where: { $0.contains(point) })

            if let intersectingFrame {
                guard let screen = getScreenWithMouse() else { return false }

                let screenHeightToWidthRatio = screen.frame.height / screen.frame.width
                let simulatorHeightToWidthRatio = intersectingFrame.height / intersectingFrame.width

                /// if the ratios match, the simulator is in full screen mode.
                if simulatorHeightToWidthRatio > screenHeightToWidthRatio {
                    var insetFrame = intersectingFrame
                    insetFrame.origin.x += deviceBezelInset.leading
                    insetFrame.origin.y += deviceBezelInset.top
                    insetFrame.size.width -= deviceBezelInset.leading + deviceBezelInset.trailing
                    insetFrame.size.height -= deviceBezelInset.top + deviceBezelInset.bottom
                    if !insetFrame.contains(point) {
                        return false
                    }
                }

                return true
            } else {
                return false
            }
        }()

        guard shouldContinue else {
            if scrollInteraction != nil { stopScroll() }
            return
        }

        if var scrollInteraction {
            scrollInteraction.targetDelta += event.scrollingDeltaY
            let deltaPerStep = (scrollInteraction.targetDelta - scrollInteraction.deltaCompleted) / CGFloat(iterationsCount)
            scrollInteraction.deltaPerStep = deltaPerStep
            self.scrollInteraction = scrollInteraction
        } else {
            let deltaPerStep = event.scrollingDeltaY / CGFloat(iterationsCount)
            let scrollInteraction = ScrollInteraction(
                initialPoint: point,
                targetDelta: event.scrollingDeltaY,
                deltaPerStep: deltaPerStep
            )
            self.scrollInteraction = scrollInteraction

            let mouseDown = CGEvent(mouseEventSource: nil, mouseType: .leftMouseDown, mouseCursorPosition: point, mouseButton: .left)
            mouseDown?.post(tap: .cghidEventTap)

            timer = Timer.scheduledTimer(withTimeInterval: scrollFrequency, repeats: true) { [weak self] _ in
                guard let self = self else { return }
                guard let scrollInteraction = self.scrollInteraction else { return }
                guard !scrollInteraction.isComplete else {
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
