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

    /// Scroll in 10 increments to the final value.
    @AppStorage("numberOfScrollSteps") var numberOfScrollSteps = Preferences.numberOfScrollSteps

    /// Stop scrolling after this timeout.
    @AppStorage("scrollInactivityTimeout") var scrollInactivityTimeout = Preferences.scrollInactivityTimeout

    /// How often to drag an increment.
    @AppStorage("scrollInterval") var scrollInterval = Preferences.scrollInterval

    /// Insets to cancel out the device bezels.
    @AppStorage("deviceBezelInsetTop") var deviceBezelInsetTop = Preferences.deviceBezelInsetTop
    @AppStorage("deviceBezelInsetLeft") var deviceBezelInsetLeft = Preferences.deviceBezelInsetLeft
    @AppStorage("deviceBezelInsetRight") var deviceBezelInsetRight = Preferences.deviceBezelInsetRight
    @AppStorage("deviceBezelInsetBottom") var deviceBezelInsetBottom = Preferences.deviceBezelInsetBottom

    /// The file path of the simulator.
    @AppStorage("simulatorPath") var simulatorPath = Preferences.simulatorPath

    /// How often to check if the simulator is open.
    @AppStorage("simulatorCheckFrequency") var simulatorCheckFrequency = Preferences.simulatorCheckFrequency

    /// The menu's maximum height.
    @AppStorage("menuMaximumHeight") var menuMaximumHeight = Preferences.menuMaximumHeight

    /// The menu's width.
    @AppStorage("menuWidth") var menuWidth = Preferences.menuWidth

    /// Multiply by the scale ratio to prevent clipping.
    var pointerWindowLength: CGFloat {
        pointerLength * pointerScaleRatio
    }

    // MARK: - General Properties

    /// Keeps track of whether accessibility permissions are granted.
    @Published var permissionsGranted = false

    /// The timer that scrolls incrementally.
    var timer: Timer?

    /// The current scroll interaction.
    @Published var scrollInteraction: ScrollInteraction?

    /// Keeps track of when to fire the timeout.
    var scrollEventActivityCounter = PassthroughSubject<Void, Never>()

    /// The window that contains the pointer.
    var pointerWindow: NSWindow?

    /// True unless the cursor goes out of the simulator bounds, in which case stop further scroll action until scroll momentum stops.
    var allowMomentumScroll = true

    /// Stores Combine sinks.
    var cancellables = Set<AnyCancellable>()

    /// Stores the accessibility permissions sink.
    var permissionsCancellable: AnyCancellable?

    /// When this is fired, redraw the menu.
    var redrawPreferences = PassthroughSubject<Void, Never>()

    override init() {
        super.init()

        /// Add the menu bar item.
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
                self.permissionsCancellable = nil /// Prevent calling `start` again.
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

        /// Stop scrolling after a timeout.
        scrollEventActivityCounter
            .dropFirst()
            .debounce(for: .seconds(scrollInactivityTimeout), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                guard let self = self else { return }

                self.stopScroll()
            }
            .store(in: &cancellables)

        /// Show the pointer whenever there is a scroll interaction.
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
