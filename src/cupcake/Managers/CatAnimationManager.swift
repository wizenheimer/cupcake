//
//  CatAnimationManager.swift
//  cupcake
//
//  Created by Nayan on 13/06/25.
//

import AppKit
import DSFDockTile

class CatAnimationManager: NSObject, ObservableObject {
    @Published var currentCatType: CatType = .classical
    @Published var currentCatState: CatState = .idle

    private let dockTile = DSFDockTile.Image()
    private var currentFrames: [NSImage] = []
    private var currentFrameIndex = 0
    private var animationTimer: Timer?

    override init() {
        super.init()
        loadAndStartAnimation(for: currentCatType, state: currentCatState)
    }

    deinit {
        stopAnimation()
    }

    @objc func stateSelected(_ sender: NSMenuItem) {
        guard let state = sender.representedObject as? CatState else { return }
        changeCat(type: currentCatType, state: state)
    }

    @objc func catSelected(_ sender: NSMenuItem) {
        guard let catType = sender.representedObject as? CatType else { return }
        changeCat(type: catType, state: currentCatState)
    }

    @objc func randomCat() {
        let randomCatType = CatType.allCases.randomElement() ?? .classical
        changeCat(type: randomCatType, state: currentCatState)
    }

    @objc func randomState() {
        let randomState = CatState.allCases.randomElement() ?? .idle
        changeCat(type: currentCatType, state: randomState)
    }

    @objc func showAbout() {
        if let url = URL(string: "https://github.com/wizenheimer/cupcake") {
            NSWorkspace.shared.open(url)
        }
    }

    private func loadFrames(for catType: CatType, state: CatState) -> [NSImage] {
        let frameRange = catType.frameRange(for: state)
        var frames: [NSImage] = []

        for frameIndex in frameRange {
            let imageName = String(format: "%02d_%@_%@", frameIndex, catType.rawValue, state.rawValue)
            if let image = NSImage(named: imageName) {
                frames.append(image)
            }
        }

        if frames.isEmpty {
            let fallback = NSImage(size: NSSize(width: 128, height: 128))
            fallback.lockFocus()
            NSColor.systemGray.set()
            NSBezierPath(rect: NSRect(x: 0, y: 0, width: 128, height: 128)).fill()
            fallback.unlockFocus()
            frames.append(fallback)
        }

        return frames
    }

    private func loadAndStartAnimation(for catType: CatType, state: CatState) {
        stopAnimation()
        currentFrames = loadFrames(for: catType, state: state)
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
        animationTimer = Timer.scheduledTimer(withTimeInterval: 0.15, repeats: true) { [weak self] _ in
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

    func changeCat(type: CatType, state: CatState) {
        currentCatType = type
        currentCatState = state
        loadAndStartAnimation(for: type, state: state)
    }
}

