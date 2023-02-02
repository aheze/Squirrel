//
//  ViewModel+Preferences.swift
//  Squirrel
//
//  Created by A. Zheng (github.com/aheze) on 2/1/23.
//  Copyright © 2023 A. Zheng. All rights reserved.
//

import SwiftUI

enum Preferences {
    static var enabled = true
    static var naturalScrolling = true
    static var pointerColor = 0x007EEF
    static var pointerLength = CGFloat(20)
    static var pointerOpacity = CGFloat(0.95)
    static var pointerScaleRatio = CGFloat(1.4)
    static var launchSimulatorOnStartup: Bool = true
    static var quitIfSimulatorClosed: Bool = true
    
    static var numberOfScrollSteps = 10
    static var scrollInactivityTimeout = CGFloat(1)
    static var scrollInterval = CGFloat(0.015)
    static var deviceBezelInsetTop = CGFloat(180)
    static var deviceBezelInsetLeft = CGFloat(20)
    static var deviceBezelInsetRight = CGFloat(20)
    static var deviceBezelInsetBottom = CGFloat(100)
    static var simulatorPath: String = "/Applications/Xcode.app/Contents/Developer/Applications/Simulator.app/"
    static var simulatorCheckFrequency: TimeInterval = 10
}

extension ViewModel {
    func resetPreferences() {
        redrawPreferences.send()
        
        enabled = Preferences.enabled
        naturalScrolling = Preferences.naturalScrolling
        pointerColor = Preferences.pointerColor
        pointerLength = Preferences.pointerLength
        pointerOpacity = Preferences.pointerOpacity
        pointerScaleRatio = Preferences.pointerScaleRatio
        launchSimulatorOnStartup = Preferences.launchSimulatorOnStartup
        quitIfSimulatorClosed = Preferences.quitIfSimulatorClosed

        numberOfScrollSteps = Preferences.numberOfScrollSteps
        scrollInactivityTimeout = Preferences.scrollInactivityTimeout
        scrollInterval = Preferences.scrollInterval
        deviceBezelInsetTop = Preferences.deviceBezelInsetTop
        deviceBezelInsetLeft = Preferences.deviceBezelInsetLeft
        deviceBezelInsetRight = Preferences.deviceBezelInsetRight
        deviceBezelInsetBottom = Preferences.deviceBezelInsetBottom
        simulatorPath = Preferences.simulatorPath
        simulatorCheckFrequency = Preferences.simulatorCheckFrequency
    }
}
