//
//  CatType.swift
//  cupcake
//
//  Created by Nayan on 13/06/25.
//

import Foundation

enum CatType: String, CaseIterable {
    case classical = "classical_cat"
    case batman = "batman_cat"
    case black = "black_cat"
    case brown = "brown_cat"
    case demonic = "demonic_cat"
    case egypt = "egypt_cat"
    case siamese = "siamese_cat"
    case threeColor = "three_color_cat"
    case tiger = "tiger_cat"
    case white = "white_cat"
    case xmas = "xmas_cat"

    var displayName: String {
        switch self {
        case .classical: return "Vanilla"
        case .batman: return "Midnight"
        case .black: return "Cocoa"
        case .brown: return "Caramel"
        case .demonic: return "Spicy"
        case .egypt: return "Honey"
        case .siamese: return "Cookies"
        case .threeColor: return "Rainbow"
        case .tiger: return "Orange"
        case .white: return "Sugar"
        case .xmas: return "Mint"
        }
    }

    func frameRange(for state: CatState) -> ClosedRange<Int> {
        switch (self, state) {
        case (.xmas, .idle): return 0...13
        case (.xmas, .jump): return 0...12
        case (_, .idle): return 0...6
        case (_, .jump): return 0...12
        }
    }
}

