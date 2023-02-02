//
//  AppDelegate+CheckSimulator.swift
//  Squirrel
//
//  Created by Kai Quan Tay on 2/2/23.
//

import Cocoa

extension AppDelegate {
    func openSimulator() -> Bool {
        let url = URL(fileURLWithPath: Preferences.simulatorPath)
        return NSWorkspace.shared.open(url)
    }

    func checkIfSimulatorIsOpen() {
        let bundleUrl = URL(fileURLWithPath: Preferences.simulatorPath)
        let applications = NSWorkspace.shared.runningApplications
        if applications.first(where: { app in
            app.bundleURL == bundleUrl
        }) == nil {
            print("Simulator is closed!")
            NSApplication.shared.terminate(self)
        } else {
            print("Simulator is open!")
        }

        // check every ten seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) { [weak self] in
            self?.checkIfSimulatorIsOpen()
        }
    }
}
