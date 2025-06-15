//
//  CatAnimationManager.swift
//  cupcake
//
//  Created by Nayan on 13/06/25.
//

import AppKit
import DSFDockTile

// MARK: - Backward Compatibility Bridge

class CatAnimationManager: NSObject, ObservableObject {
    private let flexibleManager: FlexibleAnimationManager
    
    // Legacy properties for backward compatibility
    @Published var currentCatType: CatType = .white {
        didSet {
            if let character = CharacterRegistry.shared.character(withId: currentCatType.rawValue) {
                flexibleManager.changeCharacter(to: character, animation: flexibleManager.currentAnimation)
            }
        }
    }
    
    @Published var currentCatState: CatState = .jump {
        didSet {
            if let animation = flexibleManager.currentCharacter.animation(named: currentCatState.rawValue) {
                flexibleManager.changeCharacter(to: flexibleManager.currentCharacter, animation: animation)
            }
        }
    }
    
    override init() {
        // Initialize flexible manager first
        self.flexibleManager = FlexibleAnimationManager()
        
        super.init()
        
        // Sync initial state after super.init
        updateLegacyProperties()
    }
    
    // MARK: - Legacy Menu Actions (for backward compatibility)
    
    @objc func stateSelected(_ sender: NSMenuItem) {
        guard let state = sender.representedObject as? CatState else { return }
        currentCatState = state
    }
    
    @objc func catSelected(_ sender: NSMenuItem) {
        guard let catType = sender.representedObject as? CatType else { return }
        currentCatType = catType
    }
    
    @objc func randomCat() {
        let randomCatType = CatType.allCases.randomElement() ?? .classical
        currentCatType = randomCatType
    }
    
    @objc func randomState() {
        let randomState = CatState.allCases.randomElement() ?? .idle
        currentCatState = randomState
    }
    
    @objc func showAbout() {
        flexibleManager.showAbout()
    }
    
    // MARK: - Helper Methods
    
    private func updateLegacyProperties() {
        // Update legacy properties based on flexible manager state
        if let catType = CatType.allCases.first(where: { $0.rawValue == flexibleManager.currentCharacter.id }) {
            currentCatType = catType
        }
        
        if let catState = CatState.allCases.first(where: { $0.rawValue == flexibleManager.currentAnimation.name }) {
            currentCatState = catState
        }
    }
    
    func changeCat(type: CatType, state: CatState) {
        currentCatType = type
        currentCatState = state
    }
}

// MARK: - Flexible Animation Manager

class FlexibleAnimationManager: NSObject, ObservableObject {
    @Published var currentCharacter: Character
    @Published var currentAnimation: AnimationSequence
    
    private let dockTile = DSFDockTile.Image()
    private var currentFrames: [NSImage] = []
    private var currentFrameIndex = 0
    private var animationTimer: Timer?
    
    override init() {
        // Initialize character and animation before super.init
        let registry = CharacterRegistry.shared
        let defaultCharacter = registry.allCharacters.first ?? Character(
            id: "fallback",
            displayName: "Default",
            animations: [AnimationSequence(name: "idle", displayName: "Idle", frameCount: 1)]
        )
        
        self.currentCharacter = defaultCharacter
        self.currentAnimation = defaultCharacter.animations.first ?? AnimationSequence(
            name: "idle",
            displayName: "Idle",
            frameCount: 1
        )
        
        super.init()
        loadAndStartAnimation()
    }
    
    deinit {
        stopAnimation()
    }
    
    // MARK: - Menu Actions
    
    @objc func characterSelected(_ sender: NSMenuItem) {
        guard let character = sender.representedObject as? Character else { return }
        changeCharacter(to: character, animation: character.animations.first ?? currentAnimation)
    }
    
    @objc func animationSelected(_ sender: NSMenuItem) {
        guard let animation = sender.representedObject as? AnimationSequence else { return }
        changeCharacter(to: currentCharacter, animation: animation)
    }
    
    @objc func randomCharacter() {
        let registry = CharacterRegistry.shared
        guard let randomCharacter = registry.allCharacters.randomElement() else { return }
        let randomAnimation = randomCharacter.animations.randomElement() ?? randomCharacter.animations.first!
        changeCharacter(to: randomCharacter, animation: randomAnimation)
    }
    
    @objc func randomAnimation() {
        guard let randomAnimation = currentCharacter.animations.randomElement() else { return }
        changeCharacter(to: currentCharacter, animation: randomAnimation)
    }
    
    @objc func showAbout() {
        if let url = URL(string: "https://github.com/wizenheimer/cupcake") {
            NSWorkspace.shared.open(url)
        }
    }
    
    // MARK: - Frame Loading
    
    private func loadFrames(for character: Character, animation: AnimationSequence) -> [NSImage] {
        var frames: [NSImage] = []
        
        // Try different naming conventions for maximum compatibility
        let namingPatterns = [
            // Original format: "00_classical_cat_idle"
            { (index: Int) in String(format: "%02d_%@_%@", index, character.id, animation.name) },
            // Alternative format: "classical_cat_idle_00"
            { (index: Int) in String(format: "%@_%@_%02d", character.id, animation.name, index) },
            // Simple format: "classical_cat_idle00"
            { (index: Int) in String(format: "%@_%@%02d", character.id, animation.name, index) },
            // Even simpler: "classicalcat_idle_0"
            { (index: Int) in String(format: "%@_%@_%d", character.id.replacingOccurrences(of: "_", with: ""), animation.name, index) }
        ]
        
        for frameIndex in 0..<animation.frameCount {
            var imageFound = false
            
            // Try each naming pattern
            for pattern in namingPatterns {
                let imageName = pattern(frameIndex)
                if let image = NSImage(named: imageName) {
                    frames.append(image)
                    imageFound = true
                    break
                }
            }
            
            // If no image found with any pattern, create a placeholder
            if !imageFound {
                print("Warning: Could not find image for \(character.id) - \(animation.name) - frame \(frameIndex)")
                let placeholder = createPlaceholderImage(character: character, animation: animation, frame: frameIndex)
                frames.append(placeholder)
            }
        }
        
        // If no frames at all, create at least one placeholder
        if frames.isEmpty {
            let fallback = createFallbackImage(character: character)
            frames.append(fallback)
        }
        
        return frames
    }
    
    private func createPlaceholderImage(character: Character, animation: AnimationSequence, frame: Int) -> NSImage {
        let size = NSSize(width: 128, height: 128)
        let image = NSImage(size: size)
        
        image.lockFocus()
        
        // Background
        NSColor.systemGray.withAlphaComponent(0.3).set()
        NSBezierPath(rect: NSRect(origin: .zero, size: size)).fill()
        
        // Border
        NSColor.systemBlue.set()
        let borderPath = NSBezierPath(rect: NSRect(origin: .zero, size: size))
        borderPath.lineWidth = 2
        borderPath.stroke()
        
        // Text
        let text = "\(character.displayName)\n\(animation.displayName)\nFrame \(frame)"
        let attributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 12),
            .foregroundColor: NSColor.labelColor
        ]
        let attributedString = NSAttributedString(string: text, attributes: attributes)
        let textRect = NSRect(x: 10, y: size.height/2 - 20, width: size.width - 20, height: 40)
        attributedString.draw(in: textRect)
        
        image.unlockFocus()
        return image
    }
    
    private func createFallbackImage(character: Character) -> NSImage {
        let size = NSSize(width: 128, height: 128)
        let image = NSImage(size: size)
        
        image.lockFocus()
        
        NSColor.systemRed.withAlphaComponent(0.3).set()
        NSBezierPath(rect: NSRect(origin: .zero, size: size)).fill()
        
        let text = "Missing:\n\(character.displayName)"
        let attributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.boldSystemFont(ofSize: 14),
            .foregroundColor: NSColor.labelColor
        ]
        let attributedString = NSAttributedString(string: text, attributes: attributes)
        let textRect = NSRect(x: 10, y: size.height/2 - 15, width: size.width - 20, height: 30)
        attributedString.draw(in: textRect)
        
        image.unlockFocus()
        return image
    }
    
    // MARK: - Animation Control
    
    private func loadAndStartAnimation() {
        stopAnimation()
        currentFrames = loadFrames(for: currentCharacter, animation: currentAnimation)
        currentFrameIndex = 0
        
        if let firstFrame = currentFrames.first {
            dockTile.display(firstFrame)
        }
        
        if currentFrames.count > 1 {
            startAnimation()
        }
    }
    
    private func startAnimation() {
        guard currentFrames.count > 1 else { return }
        
        animationTimer = Timer.scheduledTimer(withTimeInterval: currentAnimation.frameRate, repeats: true) { [weak self] _ in
            self?.updateFrame()
        }
    }
    
    private func stopAnimation() {
        animationTimer?.invalidate()
        animationTimer = nil
    }
    
    private func updateFrame() {
        guard currentFrames.count > 1 else { return }
        currentFrameIndex = (currentFrameIndex + 1) % currentFrames.count
        dockTile.display(currentFrames[currentFrameIndex])
    }
    
    func changeCharacter(to character: Character, animation: AnimationSequence) {
        // Validate that the animation belongs to the character
        guard character.animations.contains(where: { $0.name == animation.name }) else {
            print("Warning: Animation '\(animation.name)' not found for character '\(character.id)'")
            return
        }
        
        currentCharacter = character
        currentAnimation = animation
        loadAndStartAnimation()
    }
    
    // MARK: - Convenience Methods
    
    func changeAnimation(to animationName: String) {
        guard let animation = currentCharacter.animation(named: animationName) else {
            print("Animation '\(animationName)' not found for character '\(currentCharacter.id)'")
            return
        }
        changeCharacter(to: currentCharacter, animation: animation)
    }
    
    func changeCharacter(to characterId: String, keepAnimation: Bool = true) {
        guard let character = CharacterRegistry.shared.character(withId: characterId) else {
            print("Character '\(characterId)' not found")
            return
        }
        
        let targetAnimation: AnimationSequence
        if keepAnimation, let existingAnimation = character.animation(named: currentAnimation.name) {
            targetAnimation = existingAnimation
        } else {
            targetAnimation = character.animations.first!
        }
        
        changeCharacter(to: character, animation: targetAnimation)
    }
}
