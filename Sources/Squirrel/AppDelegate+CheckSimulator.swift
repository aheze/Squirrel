//
//  AppDelegate+CheckSimulator.swift
//  Squirrel
//
//  Created by Kai Quan Tay on 2/2/23.
//

import Cocoa

extension AppDelegate {
    func openSimulator() -> Bool {
        guard !isSimulatorOpen() && viewModel.launchSimulatorOnStartup else { return true }
        let url = URL(fileURLWithPath: viewModel.simulatorPath)
        return NSWorkspace.shared.open(url)
    }

    func checkIfSimulatorIsOpen() {
        if !isSimulatorOpen() && viewModel.quitIfSimulatorClosed {
            NSApplication.shared.terminate(self)
        }

        // check every ten seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + viewModel.simulatorCheckFrequency) { [weak self] in
            self?.checkIfSimulatorIsOpen()
        }
    }

    func isSimulatorOpen() -> Bool {
        let bundleUrl = URL(fileURLWithPath: viewModel.simulatorPath)
        let applications = NSWorkspace.shared.runningApplications
        return applications.contains { app in
            app.bundleURL == bundleUrl
        }
    }
}
