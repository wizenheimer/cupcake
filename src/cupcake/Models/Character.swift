//
//  Character.swift
//  cupcake
//
//  Created by Nayan on 15/06/25.
//

import Foundation

// MARK: - Core Data Structures

struct AnimationSequence {
    let name: String
    let displayName: String
    let frameCount: Int
    let frameRate: TimeInterval // seconds per frame
    
    init(name: String, displayName: String, frameCount: Int, frameRate: TimeInterval = 0.15) {
        self.name = name
        self.displayName = displayName
        self.frameCount = frameCount
        self.frameRate = frameRate
    }
}

struct Character {
    let id: String
    let displayName: String
    let animations: [AnimationSequence]
    
    init(id: String, displayName: String, animations: [AnimationSequence]) {
        self.id = id
        self.displayName = displayName
        self.animations = animations
    }
    
    // Helper to get animation by name
    func animation(named: String) -> AnimationSequence? {
        return animations.first { $0.name == named }
    }
}

// MARK: - Character Registry

class CharacterRegistry {
    static let shared = CharacterRegistry()
    private var characters: [Character] = []
    
    private init() {
        loadDefaultCharacters()
    }
    
    var allCharacters: [Character] {
        return characters
    }
    
    func character(withId id: String) -> Character? {
        return characters.first { $0.id == id }
    }
    
    func addCharacter(_ character: Character) {
        // Remove existing character with same ID if present
        characters.removeAll { $0.id == character.id }
        characters.append(character)
    }
    
    func removeCharacter(withId id: String) {
        characters.removeAll { $0.id == id }
    }
    
    // MARK: - Default Characters Setup
    
    private func loadDefaultCharacters() {
        // Convert existing cats to new system
        for catType in CatType.allCases {
            let character = Character(
                id: catType.rawValue,
                displayName: catType.displayName,
                animations: CatState.allCases.map { state in
                    let frameRange = catType.frameRange(for: state)
                    return AnimationSequence(
                        name: state.rawValue,
                        displayName: state.displayName,
                        frameCount: frameRange.count
                    )
                }
            )
            addCharacter(character)
        }
        
        // Add example new characters
        addNewCharacters()
    }
    
    private func addNewCharacters() {
        let zombieCat = Character(
                id: "zombie_cat",
                displayName: "Zombie",
                animations: [
                    AnimationSequence(name: "eating", displayName: "Feast", frameCount: 15, frameRate: 0.12),
                    // If you create an idle animation later, uncomment this:
                    // AnimationSequence(name: "idle", displayName: "Lurk", frameCount: 7, frameRate: 0.3),
                    // AnimationSequence(name: "attack", displayName: "Bite", frameCount: 8, frameRate: 0.08),
                    // AnimationSequence(name: "shamble", displayName: "Shamble", frameCount: 10, frameRate: 0.15)
                ]
            )
        
        let flameCat = Character(
                id: "flame_cat",
                displayName: "Inferno",
                animations: [
                    AnimationSequence(name: "jump", displayName: "Flame Leap", frameCount: 13, frameRate: 0.08),
                    // Future animations:
                    // AnimationSequence(name: "idle", displayName: "Hover", frameCount: 8, frameRate: 0.2),
                    // AnimationSequence(name: "attack", displayName: "Fire Blast", frameCount: 10, frameRate: 0.06),
                    // AnimationSequence(name: "special", displayName: "Inferno", frameCount: 15, frameRate: 0.05)
                ]
            )
        
        let lightningCat = Character(
                id: "lightning_cat",
                displayName: "Thunder",
                animations: [
                    AnimationSequence(name: "jump", displayName: "Lightning Strike", frameCount: 13, frameRate: 0.08),
                    // Future animations:
                    // AnimationSequence(name: "idle", displayName: "Hover", frameCount: 8, frameRate: 0.2),
                    // AnimationSequence(name: "attack", displayName: "Thunder Bolt", frameCount: 10, frameRate: 0.06),
                    // AnimationSequence(name: "special", displayName: "Lightning Storm", frameCount: 15, frameRate: 0.05)
                ]
            )
        
        let frostCat = Character(
                id: "frost_cat",
                displayName: "Blizzard",
                animations: [
                    AnimationSequence(name: "jump", displayName: "Ice Leap", frameCount: 13, frameRate: 0.08),
                    // Future animations:
                    // AnimationSequence(name: "idle", displayName: "Hover", frameCount: 8, frameRate: 0.2),
                    // AnimationSequence(name: "attack", displayName: "Ice Beam", frameCount: 10, frameRate: 0.06),
                    // AnimationSequence(name: "special", displayName: "Blizzard", frameCount: 15, frameRate: 0.05)
                ]
            )
        
        let shadowCat = Character(
                id: "shadow_cat",
                displayName: "Phantom",
                animations: [
                    AnimationSequence(name: "jump", displayName: "Shadow Dash", frameCount: 13, frameRate: 0.08),
                    // Future animations:
                    // AnimationSequence(name: "idle", displayName: "Hover", frameCount: 8, frameRate: 0.2),
                    // AnimationSequence(name: "attack", displayName: "Shadow Blast", frameCount: 10, frameRate: 0.06),
                    // AnimationSequence(name: "special", displayName: "Void", frameCount: 15, frameRate: 0.05)
                ]
            )
        
        
        let stormCat = Character(
                id: "storm_cat",
                displayName: "Tempest",
                animations: [
                    AnimationSequence(name: "jump", displayName: "Wind Leap", frameCount: 13, frameRate: 0.08),
                    // Future animations:
                    // AnimationSequence(name: "idle", displayName: "Hover", frameCount: 8, frameRate: 0.2),
                    // AnimationSequence(name: "attack", displayName: "Gust", frameCount: 10, frameRate: 0.06),
                    // AnimationSequence(name: "special", displayName: "Hurricane", frameCount: 15, frameRate: 0.05)
                ]
            )
        
        addCharacter(zombieCat)
        addCharacter(flameCat)
        addCharacter(frostCat)
        addCharacter(lightningCat)
        addCharacter(shadowCat)
        addCharacter(stormCat)
    }
}

// MARK: - JSON Configuration Support

extension Character {
    // For loading characters from JSON files
    init?(from dictionary: [String: Any]) {
        guard let id = dictionary["id"] as? String,
              let displayName = dictionary["displayName"] as? String,
              let animationsData = dictionary["animations"] as? [[String: Any]] else {
            return nil
        }
        
        let animations = animationsData.compactMap { animData -> AnimationSequence? in
            guard let name = animData["name"] as? String,
                  let displayName = animData["displayName"] as? String,
                  let frameCount = animData["frameCount"] as? Int else {
                return nil
            }
            
            let frameRate = animData["frameRate"] as? TimeInterval ?? 0.15
            return AnimationSequence(name: name, displayName: displayName, frameCount: frameCount, frameRate: frameRate)
        }
        
        guard !animations.isEmpty else { return nil }
        
        self.id = id
        self.displayName = displayName
        self.animations = animations
    }
    
    var dictionary: [String: Any] {
        return [
            "id": id,
            "displayName": displayName,
            "animations": animations.map { animation in
                [
                    "name": animation.name,
                    "displayName": animation.displayName,
                    "frameCount": animation.frameCount,
                    "frameRate": animation.frameRate
                ]
            }
        ]
    }
}

// MARK: - File-based Configuration Loading

extension CharacterRegistry {
    func loadCharactersFromBundle() {
        guard let path = Bundle.main.path(forResource: "Characters", ofType: "json"),
              let data = NSData(contentsOfFile: path),
              let json = try? JSONSerialization.jsonObject(with: data as Data) as? [String: Any],
              let charactersData = json["characters"] as? [[String: Any]] else {
            print("Could not load characters from bundle, using defaults")
            return
        }
        
        let loadedCharacters = charactersData.compactMap { Character(from: $0) }
        loadedCharacters.forEach { addCharacter($0) }
    }
    
    func saveCharactersToDocuments() {
        let charactersData = characters.map { $0.dictionary }
        let json = ["characters": charactersData]
        
        guard let data = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted) else {
            print("Failed to serialize characters")
            return
        }
        
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        guard let documentsDirectory = urls.first else { return }
        
        let fileURL = documentsDirectory.appendingPathComponent("CustomCharacters.json")
        
        do {
            try data.write(to: fileURL)
            print("Characters saved to: \(fileURL.path)")
        } catch {
            print("Failed to save characters: \(error)")
        }
    }
}
