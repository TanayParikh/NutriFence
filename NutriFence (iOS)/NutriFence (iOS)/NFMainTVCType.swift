//
//  NFMainTVCType.swift
//  NutriFence (iOS)
//
//  Created by Matthew Watt on 11/11/16.
//  Copyright © 2016 NutriFence. All rights reserved.
//

import Foundation

/**
 Describes the type of data the Main Table View Controller will show, namely:
    result - result of an analysis
    selection - interface allowing the user to select their preferred diet
 */

enum NFMainTVCType {
    case result(NFClassificationFetcher.ProductSafetyStatus?)
    case selection
}
