//
//  AppDelegate.swift
//  Squirrel
//
//  Created by A. Zheng (github.com/aheze) on 1/31/23.
//  Copyright © 2023 A. Zheng. All rights reserved.
//

import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    let viewModel = ViewModel()
    let popover = NSPopover()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application

        let contentView = ContentView(viewModel: viewModel)
        popover.behavior = .transient
        popover.contentSize = NSSize(width: 360, height: 360)
        popover.contentViewController = NSHostingController(rootView: contentView)
        viewModel.popover = popover
        popover.delegate = viewModel

        if !openSimulator() {
            print("Error opening simulator!")
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + Preferences.simulatorCheckFrequency) { [weak self] in
            self?.checkIfSimulatorIsOpen()
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
}
