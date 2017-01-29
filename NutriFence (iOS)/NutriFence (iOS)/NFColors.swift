//
//  NFColors.swift
//  NutriFence (iOS)
//
//  Created by Matthew Watt on 11/11/16.
//  Copyright © 2016 NutriFence. All rights reserved.
//

import UIKit

struct NFColors {
    
    static let text = UIColor(red: 175, green: 175, blue: 175)
    
    /**
     Serve as values to be passed into the gradient(_ view: UIView, color: NFGradientColor) function
     */
    public enum GradientColor {
        case red
        case green
        case purple
    }
    
    /**
     Takes a view and an NFGradientColor converts it into a gradient within the bounds of the passed view
     - returns:
     A CAGradientLayer that with bounds of view.bounds and the color specified.
     
     - parameters:
        - view: the view whose bounds will contain the gradient
        - color: the color to use when creating the gradient
     
    */
    static func gradient(_ view: UIView, color: GradientColor) -> CAGradientLayer {
        let gradient = CAGradientLayer()
        gradient.frame = view.bounds
        switch color {
        case .green:
            gradient.colors = [greenColors["top"]!.cgColor, greenColors["bottom"]!.cgColor]
        case .red:
            gradient.colors = [redColors["top"]!.cgColor, redColors["bottom"]!.cgColor]
        case .purple:
            gradient.colors = [purpleColors["top"]!.cgColor, purpleColors["bottom"]!.cgColor]
        }
        return gradient
    }
    
    /**
     Private members used to construct the gradients
     */
    
    private static let greenColors = ["top": UIColor(red: 40, green: 64, blue: 40),
                                      "bottom": UIColor(red: 40, green: 48, blue: 40)]
    private static let redColors = ["top": UIColor(red: 83, green: 38, blue: 38),
                                    "bottom": UIColor(red: 83, green: 38, blue: 38)]
    private static let purpleColors = ["top": UIColor(red: 69, green: 58, blue: 73),
                                       "bottom": UIColor(red: 63, green: 58, blue: 73)]
}
