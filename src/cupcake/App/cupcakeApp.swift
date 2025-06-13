//
//  cupcakeApp.swift
//  cupcake
//
//  Created by Nayan on 13/06/25.
//

import SwiftUI

@main
struct cupcakeApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            EmptyView()
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .defaultSize(width: 0, height: 0)
    }
}
