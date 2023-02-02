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

    func getWindows() -> [[String: Any]] {
        let options = CGWindowListOption(arrayLiteral: .excludeDesktopElements, .optionOnScreenOnly)
        let windowsListInfo = CGWindowListCopyWindowInfo(options, CGWindowID(0))
        let infoList = windowsListInfo as! [[String: Any]]
        let visibleWindows = infoList.filter { $0["kCGWindowLayer"] as! Int == 0 }

        return visibleWindows
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
}
