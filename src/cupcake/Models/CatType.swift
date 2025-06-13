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
        case .classical: return "Classical Cat"
        case .batman: return "Batman Cat"
        case .black: return "Black Cat"
        case .brown: return "Brown Cat"
        case .demonic: return "Demon Cat"
        case .egypt: return "Egyptian Cat"
        case .siamese: return "Siamese Cat"
        case .threeColor: return "Calico Cat"
        case .tiger: return "Tiger Cat"
        case .white: return "White Cat"
        case .xmas: return "Christmas Cat"
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

