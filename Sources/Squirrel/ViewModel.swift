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

    @AppStorage("enabled") var enabled = Preferences.enabled
    @AppStorage("naturalScrolling") var naturalScrolling = Preferences.naturalScrolling
    @AppStorage("pointerColor") var pointerColor = Preferences.pointerColor
    @AppStorage("pointerLength") var pointerLength = Preferences.pointerLength
    @AppStorage("pointerOpacity") var pointerOpacity = Preferences.pointerOpacity
    @AppStorage("pointerScaleRatio") var pointerScaleRatio = Preferences.pointerScaleRatio
    @AppStorage("launchSimulatorOnStartup") var launchSimulatorOnStartup = Preferences.launchSimulatorOnStartup
    @AppStorage("quitIfSimulatorClosed") var quitIfSimulatorClosed = Preferences.quitIfSimulatorClosed

    // MARK: - Status Bar Properties

    var statusBar = NSStatusBar()
    lazy var statusItem = statusBar.statusItem(withLength: 28.0)
    var popover: NSPopover?

    // MARK: - Scroll Properties

    /// make it to the final value in 10 steps
    @AppStorage("numberOfScrollSteps") var numberOfScrollSteps = Preferences.numberOfScrollSteps
    @AppStorage("scrollInactivityTimeout") var scrollInactivityTimeout = Preferences.scrollInactivityTimeout
    @AppStorage("scrollInterval") var scrollInterval = Preferences.scrollInterval
    @AppStorage("deviceBezelInsetTop") var deviceBezelInsetTop = Preferences.deviceBezelInsetTop
    @AppStorage("deviceBezelInsetLeft") var deviceBezelInsetLeft = Preferences.deviceBezelInsetLeft
    @AppStorage("deviceBezelInsetRight") var deviceBezelInsetRight = Preferences.deviceBezelInsetRight
    @AppStorage("deviceBezelInsetBottom") var deviceBezelInsetBottom = Preferences.deviceBezelInsetBottom
    @AppStorage("simulatorPath") var simulatorPath = Preferences.simulatorPath
    @AppStorage("simulatorCheckFrequency") var simulatorCheckFrequency = Preferences.simulatorCheckFrequency
    var pointerWindowLength: CGFloat {
        pointerLength * 5
    }

    // MARK: - General Properties

    @Published var permissionsGranted = false
    var timer: Timer?
    @Published var scrollInteraction: ScrollInteraction?
    var scrollEventActivityCounter = PassthroughSubject<Void, Never>()
    var pointerWindow: NSWindow?
    var allowMomentumScroll = true

    var cancellables = Set<AnyCancellable>()
    var permissionsCancellable: AnyCancellable?
    var redrawPreferences = PassthroughSubject<Void, Never>()

    override init() {
        super.init()

        statusBar = NSStatusBar.system
        statusItem = statusBar.statusItem(withLength: NSStatusItem.squareLength)

        if let statusBarButton = statusItem.button {
            statusBarButton.image = NSImage(named: "MenuBarIcon")
            statusBarButton.image?.size = NSSize(width: 18, height: 18)
            statusBarButton.image?.isTemplate = true
            statusBarButton.action = #selector(togglePopover)
            statusBarButton.target = self
        }

        loadPermissions()

        permissionsCancellable = $permissionsGranted.sink { [weak self] permissionsGranted in
            guard let self = self else { return }
            guard permissionsGranted else { return }

            if permissionsGranted {
                self.start()
                self.permissionsCancellable = nil
            }
        }

        start()
    }

    // MARK: - Permissions

    func loadPermissions() {
        let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeRetainedValue() as NSString: false]
        let granted = AXIsProcessTrustedWithOptions(options)
        permissionsGranted = granted

        if !granted {
            DistributedNotificationCenter.default().addObserver(forName: NSNotification.Name("com.apple.accessibility.api"), object: nil, queue: nil) { _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.loadPermissions()
                }
            }
        }
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
                    x: scrollInteraction.initialPoint.x - (self.pointerWindowLength / 2),
                    y: scrollInteraction.initialPoint.y + (self.pointerWindowLength / 2)
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
