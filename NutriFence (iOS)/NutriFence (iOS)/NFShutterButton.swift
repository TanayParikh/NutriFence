//
//  NFShutterButton.swift
//  NutriFence (iOS)
//
//  Created by Matthew Watt on 12/18/16.
//  Copyright © 2016 NutriFence. All rights reserved.
//

import UIKit

class NFShutterButton: UIButton {
    
    var shutterColor: UIColor!
    override func awakeFromNib() {
        layer.backgroundColor = UIColor(red: 69, green: 58, blue: 73).withAlphaComponent(0.7).cgColor
        shutterColor = UIColor(red: 69, green: 58, blue: 73).withAlphaComponent(0.7)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.width * 0.5
        layer.borderColor = UIColor(red: 175, green: 175, blue: 175).cgColor
        layer.borderWidth = layer.bounds.width * 0.05
    }
    
    override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                layer.backgroundColor = UIColor(red: 49, green: 38, blue: 53).cgColor
            } else {
                layer.backgroundColor = shutterColor.cgColor
            }
        }
    }
}
