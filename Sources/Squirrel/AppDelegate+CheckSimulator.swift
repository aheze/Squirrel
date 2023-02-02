//
//  AppDelegate+CheckSimulator.swift
//  Squirrel
//
//  Created by Kai Quan Tay on 2/2/23.
//

import Cocoa

extension AppDelegate {
    func openSimulator() -> Bool {
        guard !isSimulatorOpen() && Preferences.launchSimulatorOnStartup else { return true }
        let url = URL(fileURLWithPath: Preferences.simulatorPath)
        return NSWorkspace.shared.open(url)
    }

    func checkIfSimulatorIsOpen() {
        if !isSimulatorOpen() && Preferences.quitIfSimulatorClosed {
            print("Simulator is closed!")
            NSApplication.shared.terminate(self)
        } else {
            print("Simulator is open!")
        }

        // check every ten seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + Preferences.simulatorCheckFrequency) { [weak self] in
            self?.checkIfSimulatorIsOpen()
        }
    }

    func isSimulatorOpen() -> Bool {
        let bundleUrl = URL(fileURLWithPath: Preferences.simulatorPath)
        let applications = NSWorkspace.shared.runningApplications
        return applications.contains { app in
            app.bundleURL == bundleUrl
        }
    }
}
