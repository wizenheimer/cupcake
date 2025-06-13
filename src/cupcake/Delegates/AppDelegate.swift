//
//  AppDelegate.swift
//  cupcake
//
//  Created by Nayan on 13/06/25.
//

import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    var catManager: CatAnimationManager!

    func applicationDidFinishLaunching(_ notification: Notification) {
        catManager = CatAnimationManager()

        NSApp.setActivationPolicy(.regular)

        DispatchQueue.main.async {
            NSApp.windows.forEach { window in
                window.orderOut(nil)
            }
        }
    }

    func applicationDockMenu(_ sender: NSApplication) -> NSMenu? {
        guard let catManager = catManager else { return nil }

        let menu = NSMenu()

        // Cat submenu
        let catMenuItem = NSMenuItem(title: "Cat", action: nil, keyEquivalent: "")
        let catSubmenu = NSMenu(title: "Cat")
        for catType in CatType.allCases {
            let item = NSMenuItem(title: catType.displayName, action: #selector(catManager.catSelected(_:)), keyEquivalent: "")
            item.target = catManager
            item.representedObject = catType
            item.state = catType == catManager.currentCatType ? .on : .off
            catSubmenu.addItem(item)
        }
        catSubmenu.addItem(NSMenuItem.separator())
        let randomCatItem = NSMenuItem(title: "Random Cat", action: #selector(catManager.randomCat), keyEquivalent: "")
        randomCatItem.target = catManager
        catSubmenu.addItem(randomCatItem)
        catMenuItem.submenu = catSubmenu
        menu.addItem(catMenuItem)

        // States submenu
        let statesMenuItem = NSMenuItem(title: "States", action: nil, keyEquivalent: "")
        let statesSubmenu = NSMenu(title: "States")
        for state in CatState.allCases {
            let item = NSMenuItem(title: state.displayName, action: #selector(catManager.stateSelected(_:)), keyEquivalent: "")
            item.target = catManager
            item.representedObject = state
            item.state = state == catManager.currentCatState ? .on : .off
            statesSubmenu.addItem(item)
        }
        statesSubmenu.addItem(NSMenuItem.separator())
        let randomStateItem = NSMenuItem(title: "Random State", action: #selector(catManager.randomState), keyEquivalent: "")
        randomStateItem.target = catManager
        statesSubmenu.addItem(randomStateItem)
        statesMenuItem.submenu = statesSubmenu
        menu.addItem(statesMenuItem)

        menu.addItem(NSMenuItem.separator())

        let aboutItem = NSMenuItem(title: "About", action: #selector(catManager.showAbout), keyEquivalent: "")
        aboutItem.target = catManager
        menu.addItem(aboutItem)

        return menu
    }
}

