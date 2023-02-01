//
//  ViewController.swift
//  Squirrel
//
//  Created by A. Zheng (github.com/aheze) on 1/31/23.
//  Copyright © 2023 A. Zheng. All rights reserved.
//

import Cocoa
import Combine
import CoreGraphics
import SwiftUI

struct ScrollInteraction {
    var initialPoint: CGPoint
    var targetDelta: CGFloat
    var deltaPerStep: CGFloat
    var deltaCompleted = CGFloat(0)

    var isComplete: Bool {
        if targetDelta >= 0 {
            return deltaCompleted > targetDelta
        } else {
            return deltaCompleted < targetDelta
        }
    }
}

class ViewController: NSViewController {
    /// make it to the final value in 10 steps
    let iterationsCount = 10
    let deviceBezelInset = EdgeInsets(top: 150, leading: 20, bottom: 50, trailing: 20)
    let scrollInactivityTimeout = CGFloat(0.75)

    var timer: Timer?
    var scrollInteraction: ScrollInteraction?
    var scrollEventActivityCounter = PassthroughSubject<Void, Never>()
    var cancellables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()

        NSEvent.addLocalMonitorForEvents(matching: [.mouseMoved]) { event in
            self.processMove(event: event)
            return event
        }
        NSEvent.addGlobalMonitorForEvents(matching: [.mouseMoved]) { event in
            self.processMove(event: event)
        }

        NSEvent.addLocalMonitorForEvents(matching: [.scrollWheel]) { event in
            self.processScroll(event: event)
            return event
        }

        NSEvent.addGlobalMonitorForEvents(matching: [.scrollWheel]) { event in
            self.processScroll(event: event)
        }

        scrollEventActivityCounter
            .debounce(for: .seconds(scrollInactivityTimeout), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                guard let self = self else { return }

                self.stopScroll()
            }
            .store(in: &cancellables)
    }

    func processMove(event: NSEvent) {
        if let scrollInteraction {
            let point = getPoint(event: event)

            /// make sure it moved a distance (prevent activating buttons)
            guard abs(point.y - scrollInteraction.initialPoint.y) > 10 else { return }

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

            timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { [weak self] _ in
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

    func getPoint(event: NSEvent) -> CGPoint {
        guard let screen = getScreenWithMouse() else { return .zero }
        let point = CGPoint(x: event.locationInWindow.x, y: screen.frame.height - event.locationInWindow.y)
        return point
    }

    func getScreenWithMouse() -> NSScreen? {
        let mouseLocation = NSEvent.mouseLocation
        let screens = NSScreen.screens
        let screenWithMouse = (screens.first { NSMouseInRect(mouseLocation, $0.frame, false) })

        return screenWithMouse
    }

    func getSimulatorWindowFrames() -> [CGRect] {
        let windows = getWindows()
        let frames: [CGRect] = windows.compactMap { window in
            if let name = window["kCGWindowOwnerName"] as? String, name == "Simulator" {
                if let frameDictionary = window["kCGWindowBounds"] as? [String: Int] {
                    guard
                        let x = frameDictionary["X"],
                        let y = frameDictionary["Y"],
                        let width = frameDictionary["Width"],
                        let height = frameDictionary["Height"]
                    else { return nil }

                    let frame = CGRect(x: x, y: y, width: width, height: height)
                    return frame
                }
            }
            return nil
        }

        return frames
    }

    func getWindows() -> [[String: Any]] {
        let options = CGWindowListOption(arrayLiteral: .excludeDesktopElements, .optionOnScreenOnly)
        let windowsListInfo = CGWindowListCopyWindowInfo(options, CGWindowID(0))
        let infoList = windowsListInfo as! [[String: Any]]
        let visibleWindows = infoList.filter { $0["kCGWindowLayer"] as! Int == 0 }

        return visibleWindows
    }
}
