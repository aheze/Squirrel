//
//  ViewModel.swift
//  Squirrel
//
//  Created by A. Zheng (github.com/aheze) on 1/31/23.
//  Copyright © 2023 A. Zheng. All rights reserved.
//

import Combine
import SwiftUI

class ViewModel: NSObject, ObservableObject {
    // MARK: - Storage

    @AppStorage("enabled") var enabled = true
    @AppStorage("naturalScrolling") var naturalScrolling = true

    // MARK: - Status Bar Properties

    var statusBar = NSStatusBar()
    lazy var statusItem = statusBar.statusItem(withLength: 28.0)
    var popover: NSPopover?

    // MARK: - Scroll Properties

    /// make it to the final value in 10 steps
    let iterationsCount = 10
    let deviceBezelInset = EdgeInsets(top: 150, leading: 20, bottom: 50, trailing: 20)
    let scrollInactivityTimeout = CGFloat(0.5)
    let scrollCancelDistance = CGFloat(10)
    let scrollFrequency = CGFloat(0.02)

    var timer: Timer?
    var scrollInteraction: ScrollInteraction?
    var scrollEventActivityCounter = PassthroughSubject<Void, Never>()
    var cancellables = Set<AnyCancellable>()

    override init() {
        super.init()

        statusBar = NSStatusBar()
        statusItem = statusBar.statusItem(withLength: 28.0)

        if let statusBarButton = statusItem.button {
            statusBarButton.image = NSImage(systemSymbolName: "gearshape.fill", accessibilityDescription: nil)
            statusBarButton.image?.size = NSSize(width: 18.0, height: 18.0)
            statusBarButton.image?.isTemplate = true
            statusBarButton.action = #selector(togglePopover)
            statusBarButton.target = self
        }

        start()
    }

    // MARK: - Start Listening To Cursor Events

    func start() {
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

    // MARK: - Status Bar Methods

    @objc func togglePopover(sender: AnyObject) {
        if popover?.isShown == true {
            hidePopover(sender)
        } else {
            showPopover(sender)
        }
    }

    func showPopover(_ sender: AnyObject) {
        if let statusBarButton = statusItem.button {
            popover?.show(relativeTo: statusBarButton.bounds, of: statusBarButton, preferredEdge: NSRectEdge.maxY)

            /// From https://stackoverflow.com/a/73322639/14351818 - to dismiss the popover after tapping outside
            popover?.contentViewController?.view.window?.makeKey()
        }
    }

    func hidePopover(_ sender: AnyObject) {
        popover?.performClose(sender)
    }
}
