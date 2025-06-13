//
//  CatState.swift
//  cupcake
//
//  Created by Nayan on 13/06/25.
//

import Foundation

enum CatState: String, CaseIterable {
    case idle = "idle"
    case jump = "jump"

    var displayName: String {
        switch self {
        case .idle: return "Chill"
        case .jump: return "Attack"
        }
    }
}

