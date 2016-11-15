//
//  NFGradientColors.swift
//  NutriFence (iOS)
//
//  Created by Matthew Watt on 11/11/16.
//  Copyright © 2016 NutriFence. All rights reserved.
//

import UIKit

enum NFGradientColors {
    
    case red
    case green
    case purple
    
    private static let greenColors = ["top": UIColor(red: 40, green: 64, blue: 40),
                         "bottom": UIColor(red: 40, green: 48, blue: 40)]
    private static let redColors = ["top": UIColor(red: 83, green: 38, blue: 38),
                       "bottom": UIColor(red: 83, green: 38, blue: 38)]
    private static let purpleColors = ["top": UIColor(red: 69, green: 58, blue: 73),
                          "bottom": UIColor(red: 63, green: 58, blue: 73)]
    
    /**
     Takes a UIColor that is either the default red, green or purple colors and converts it into a gradient.
     - returns:
     A CAGradientLayer that with bounds of view.bounds and the same color as the passed UIColor. If the color is not red, green or purple, an empty CAGradientLayer
     
     - parameters:
        - view: the view whose bounds will contain the gradient
        - withColor: the color to use when creating the gradient
     
    */
    
    static func gradientInView(_ view: UIView, withColor color: UIColor) -> CAGradientLayer {
        let gradient = CAGradientLayer()
        gradient.frame = view.bounds
        switch color {
        case UIColor.green:
            gradient.colors = [greenColors["top"]!.cgColor, greenColors["bottom"]!.cgColor]
        case UIColor.red:
            gradient.colors = [redColors["top"]!.cgColor, redColors["bottom"]!.cgColor]
        case UIColor.purple:
            gradient.colors = [purpleColors["top"]!.cgColor, purpleColors["bottom"]!.cgColor]
        default: break
        }
        return gradient
    }
}
