//
//  ViewModel+Utilities.swift
//  Squirrel
//
//  Created by A. Zheng (github.com/aheze) on 1/31/23.
//  Copyright © 2023 A. Zheng. All rights reserved.
//

import Cocoa

// MARK: - Utilities

extension ViewModel {
    func getPoint(event: NSEvent) -> CGPoint {
        let point = convertPointToScreen(point: event.locationInWindow)
        return point
    }

    func convertPointToScreen(point: CGPoint) -> CGPoint {
        guard let screen = getScreenWithMouse() else { return .zero }
        let point = CGPoint(x: point.x, y: screen.frame.height - point.y)
        return point
    }

    func getScreenWithMouse() -> NSScreen? {
        let mouseLocation = NSEvent.mouseLocation
        let screens = NSScreen.screens
        let screenWithMouse = screens.first { NSMouseInRect(mouseLocation, $0.frame, false) } ?? screens.first

        return screenWithMouse
    }

    func getWindowInformation() -> [[String: Any]] {
        let options = CGWindowListOption(arrayLiteral: .excludeDesktopElements, .optionOnScreenOnly)
        let windowsListInfo = CGWindowListCopyWindowInfo(options, CGWindowID(0))
        let infoList = windowsListInfo as! [[String: Any]]

        /// Topmost window is first in this array.
        let visibleWindowInformation = infoList.filter { $0["kCGWindowLayer"] as! Int == 0 }

        return visibleWindowInformation
    }

    func getWindows() -> [(name: String, frame: CGRect)] {
        let windowInformation = getWindowInformation()
        let windows: [(String, CGRect)] = windowInformation.compactMap { window in
            if let name = window["kCGWindowOwnerName"] as? String {
                if let frameDictionary = window["kCGWindowBounds"] as? [String: Int] {
                    guard
                        let x = frameDictionary["X"],
                        let y = frameDictionary["Y"],
                        let width = frameDictionary["Width"],
                        let height = frameDictionary["Height"]
                    else { return nil }

                    let frame = CGRect(x: x, y: y, width: width, height: height)
                    return (name, frame)
                }
            }
            return nil
        }
        return windows
    }

    /**
     - parameter frames: The simulator window frames, inset by the specified bezel insets.
     - parameter ignoredFrames: Portions of overlapping windows. Ignore scrolling if the mouse is within these frames.
     */
    func getSimulatorWindowFrames() -> (simulatorFrames: [CGRect], ignoredFrames: [CGRect]) {
        let windows = getWindows()

        var simulatorFrames = [CGRect]()
        var ignoredFrames = [CGRect]()

        for index in windows.indices {
            let window = windows[index]
            if window.name == "Simulator" {
                var frame = window.frame

                frame.origin.x += deviceBezelInsetLeft
                frame.origin.y += deviceBezelInsetTop
                frame.size.width -= deviceBezelInsetLeft + deviceBezelInsetRight
                frame.size.height -= deviceBezelInsetTop + deviceBezelInsetBottom

                simulatorFrames.append(frame)

                let windowsInFront = windows.prefix(index)
                for windowInFront in windowsInFront {
                    if frame.intersects(windowInFront.frame) {
                        let intersection = frame.intersection(windowInFront.frame)
                        ignoredFrames.append(intersection)
                    }
                }
            }
        }

        return (simulatorFrames, ignoredFrames)
    }
}

//
// frame.origin.x += deviceBezelInsetLeft
// frame.origin.y += deviceBezelInsetTop
// frame.size.width -= deviceBezelInsetLeft + deviceBezelInsetRight
// frame.size.height -= deviceBezelInsetTop + deviceBezelInsetBottom
