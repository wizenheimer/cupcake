//
//  AppDelegate.swift
//  cupcake
//
//  Created by Nayan on 13/06/25.
//

import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    var animationManager: FlexibleAnimationManager!
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        animationManager = FlexibleAnimationManager()
        
        NSApp.setActivationPolicy(.regular)
        
        DispatchQueue.main.async {
            NSApp.windows.forEach { window in
                window.orderOut(nil)
            }
        }
    }
    
    func applicationDockMenu(_ sender: NSApplication) -> NSMenu? {
        guard let animationManager = animationManager else { return nil }
        
        let menu = NSMenu()
        let registry = CharacterRegistry.shared
        
        // Characters submenu
        let charactersMenuItem = NSMenuItem(title: "Characters", action: nil, keyEquivalent: "")
        let charactersSubmenu = NSMenu(title: "Characters")
        
        for character in registry.allCharacters {
            let item = NSMenuItem(
                title: character.displayName,
                action: #selector(animationManager.characterSelected(_:)),
                keyEquivalent: ""
            )
            item.target = animationManager
            item.representedObject = character
            item.state = character.id == animationManager.currentCharacter.id ? .on : .off
            charactersSubmenu.addItem(item)
        }
        
        charactersSubmenu.addItem(NSMenuItem.separator())
        let randomCharacterItem = NSMenuItem(
            title: "Random Character",
            action: #selector(animationManager.randomCharacter),
            keyEquivalent: ""
        )
        randomCharacterItem.target = animationManager
        charactersSubmenu.addItem(randomCharacterItem)
        charactersMenuItem.submenu = charactersSubmenu
        menu.addItem(charactersMenuItem)
        
        // Animations submenu (dynamic based on current character)
        let animationsMenuItem = NSMenuItem(title: "Animations", action: nil, keyEquivalent: "")
        let animationsSubmenu = NSMenu(title: "Animations")
        
        for animation in animationManager.currentCharacter.animations {
            let item = NSMenuItem(
                title: animation.displayName,
                action: #selector(animationManager.animationSelected(_:)),
                keyEquivalent: ""
            )
            item.target = animationManager
            item.representedObject = animation
            item.state = animation.name == animationManager.currentAnimation.name ? .on : .off
            animationsSubmenu.addItem(item)
        }
        
        animationsSubmenu.addItem(NSMenuItem.separator())
        let randomAnimationItem = NSMenuItem(
            title: "Random Animation",
            action: #selector(animationManager.randomAnimation),
            keyEquivalent: ""
        )
        randomAnimationItem.target = animationManager
        animationsSubmenu.addItem(randomAnimationItem)
        animationsMenuItem.submenu = animationsSubmenu
        menu.addItem(animationsMenuItem)
        
        // Character info
        menu.addItem(NSMenuItem.separator())
        let infoItem = NSMenuItem(
            title: "Current: \(animationManager.currentCharacter.displayName) - \(animationManager.currentAnimation.displayName)",
            action: nil,
            keyEquivalent: ""
        )
        infoItem.isEnabled = false
        menu.addItem(infoItem)
        
        // Management options
        menu.addItem(NSMenuItem.separator())
        
        let managementMenuItem = NSMenuItem(title: "Manage", action: nil, keyEquivalent: "")
        let managementSubmenu = NSMenu(title: "Manage")
        
        let reloadItem = NSMenuItem(
            title: "Reload Characters",
            action: #selector(reloadCharacters),
            keyEquivalent: ""
        )
        reloadItem.target = self
        managementSubmenu.addItem(reloadItem)
        
        let exportItem = NSMenuItem(
            title: "Export Characters",
            action: #selector(exportCharacters),
            keyEquivalent: ""
        )
        exportItem.target = self
        managementSubmenu.addItem(exportItem)
        
        managementMenuItem.submenu = managementSubmenu
        menu.addItem(managementMenuItem)
        
        menu.addItem(NSMenuItem.separator())
        
        let aboutItem = NSMenuItem(
            title: "About",
            action: #selector(animationManager.showAbout),
            keyEquivalent: ""
        )
        aboutItem.target = animationManager
        menu.addItem(aboutItem)
        
        return menu
    }
    
    @objc func reloadCharacters() {
        CharacterRegistry.shared.loadCharactersFromBundle()
        
        // Show notification using modern UserNotifications framework
        showNotification(title: "Characters Reloaded",
                        body: "Character definitions have been reloaded from configuration files.")
    }
    
    @objc func exportCharacters() {
        CharacterRegistry.shared.saveCharactersToDocuments()
        
        // Show notification with file location
        showNotification(title: "Characters Exported",
                        body: "Character definitions exported to Documents folder.")
    }
    
    private func showNotification(title: String, body: String) {
        // For macOS 11.0+, we'll use a simple alert instead of deprecated NSUserNotification
        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.messageText = "Cupcake"
            alert.informativeText = "\(title)\n\(body)"
            alert.alertStyle = .informational
            alert.addButton(withTitle: "OK")
            alert.runModal()
        }
    }
}
