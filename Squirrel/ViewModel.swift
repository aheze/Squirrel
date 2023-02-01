//
//  ViewModel.swift
//  Squirrel
//
//  Created by A. Zheng (github.com/aheze) on 1/31/23.
//  Copyright © 2023 A. Zheng. All rights reserved.
//

import Combine
import SwiftUI

class ViewModel: NSObject {
    /// make it to the final value in 10 steps
    let iterationsCount = 10
    let deviceBezelInset = EdgeInsets(top: 150, leading: 20, bottom: 50, trailing: 20)
    let scrollInactivityTimeout = CGFloat(0.75)

    var timer: Timer?
    var scrollInteraction: ScrollInteraction?
    var scrollEventActivityCounter = PassthroughSubject<Void, Never>()
    var cancellables = Set<AnyCancellable>()

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
}
