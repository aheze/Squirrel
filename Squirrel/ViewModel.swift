//
//  ViewModel.swift
//  Squirrel
//
//  Created by A. Zheng (github.com/aheze) on 1/31/23.
//  Copyright © 2023 A. Zheng. All rights reserved.
//

import ApplicationServices
import Combine
import SwiftUI

class ViewModel: NSObject, ObservableObject {
    // MARK: - Preferences

    @AppStorage("enabled") var enabled = true
    @AppStorage("naturalScrolling") var naturalScrolling = true
    @AppStorage("color") var color = 0x007EEF
    

    // MARK: - Status Bar Properties

    var statusBar = NSStatusBar()
    lazy var statusItem = statusBar.statusItem(withLength: 28.0)
    var popover: NSPopover?

    // MARK: - Scroll Properties

    /// make it to the final value in 10 steps
    @AppStorage("numberOfScrollSteps") var numberOfScrollSteps = 10
    @AppStorage("deviceBezelInsetTop") var deviceBezelInsetTop = CGFloat(180)
    @AppStorage("deviceBezelInsetLeft") var deviceBezelInsetLeft = CGFloat(20)
    @AppStorage("deviceBezelInsetRight") var deviceBezelInsetRight = CGFloat(20)
    @AppStorage("deviceBezelInsetBottom") var deviceBezelInsetBottom = CGFloat(100)
    @AppStorage("scrollInactivityTimeout") var scrollInactivityTimeout = CGFloat(1)
    @AppStorage("pointerLength") var pointerLength = CGFloat(50)
    @AppStorage("scrollFrequency") var scrollFrequency = CGFloat(0.015)
    
    var timer: Timer?
    @Published var scrollInteraction: ScrollInteraction?
    var scrollEventActivityCounter = PassthroughSubject<Void, Never>()
    var cancellables = Set<AnyCancellable>()
    var pointerWindow: NSWindow?
    var allowMomentumScroll = true

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
        NSEvent.addLocalMonitorForEvents(matching: [.scrollWheel]) { [weak self] event in
            self?.processScroll(event: event)
            return event
        }

        NSEvent.addGlobalMonitorForEvents(matching: [.scrollWheel]) { [weak self] event in
            self?.processScroll(event: event)
        }

        NSEvent.addLocalMonitorForEvents(matching: [.keyUp]) { [weak self] event in
            self?.processKey(event: event)
            return event
        }

        NSEvent.addGlobalMonitorForEvents(matching: [.keyUp]) { [weak self] event in
            self?.processKey(event: event)
        }

        scrollEventActivityCounter
            .dropFirst()
            .debounce(for: .seconds(scrollInactivityTimeout), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                guard let self = self else { return }

                self.stopScroll()
            }
            .store(in: &cancellables)

        $scrollInteraction.sink { [weak self] scrollInteraction in
            guard let self = self else { return }

            if let scrollInteraction {
                if self.pointerWindow == nil {
                    let pointerView = PointerView(viewModel: self)
                    let hostingController = NSHostingController(rootView: pointerView)
                    let window = NSWindow(contentViewController: hostingController)
                    window.isOpaque = false
                    window.backgroundColor = .clear
                    window.styleMask = .borderless
                    window.hasShadow = false
                    window.orderFront(nil)
                    window.level = .init(rawValue: 100)

                    self.pointerWindow = window
                }

                let point = CGPoint(
                    x: scrollInteraction.initialPoint.x - (self.pointerLength / 2),
                    y: scrollInteraction.initialPoint.y + (self.pointerLength / 2)
                )

                let convertedPoint = self.convertPointToScreen(point: point)
                self.pointerWindow?.setFrameOrigin(convertedPoint)
            } else {
                /// Delay removing the window to allow a SwiftUI animation.
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    guard self.scrollInteraction == nil else { return }
                    self.pointerWindow?.close()
                    self.pointerWindow = nil
                }
            }
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

extension ViewModel: NSPopoverDelegate {
    func popoverWillShow(_ notification: Notification) {
        NSApp.activate(ignoringOtherApps: true)
    }
}
