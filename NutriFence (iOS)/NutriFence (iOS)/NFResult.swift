//
//  NFResult.swift
//  NutriFence (iOS)
//
//  Created by Matthew Watt on 11/13/16.
//  Copyright © 2016 NutriFence. All rights reserved.
//

import Foundation

enum NFProductSafetyStatus {
    case safe
    case unsafe
    
    var description: String {
        switch self {
        case .safe:
            return "Safe"
        case .unsafe:
            return "Unsafe"
        }
    }
}

/**
    A type to contain the results of an ingredient analysis
 */
struct NFResult: CustomDebugStringConvertible {
    var safetyStatus: NFProductSafetyStatus
    var ingredients: [NFIngredient]
    
    var debugDescription: String {
        return "Status: \(self.safetyStatus.description)\nIngredients:\n\t\(ingredients)"
    }
}
