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
}

struct NFResult {
    var safetyStatus: NFProductSafetyStatus
    var ingredients: [NFIngredient]
}
