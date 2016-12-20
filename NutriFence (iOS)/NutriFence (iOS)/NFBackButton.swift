//
//  NFBackButton.swift
//  NutriFence (iOS)
//
//  Created by Matthew Watt on 12/19/16.
//  Copyright © 2016 NutriFence. All rights reserved.
//

import UIKit

class NFBackButton: UIButton {
    
    private var arrowPath: UIBezierPath!
    private var buttonAlpha: CGFloat! = 0.5
    
    override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                buttonAlpha = 0.8
                setNeedsDisplay()
            } else {
                buttonAlpha = 0.5
                setNeedsDisplay()
            }
        }
    }

    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        let insetRect = bounds.insetBy(dx: bounds.width * 0.2, dy: bounds.width * 0.2)
        arrowPath = UIBezierPath()
        arrowPath.move(to: CGPoint(x: insetRect.origin.x + insetRect.width * 0.5, y: insetRect.origin.y))
        arrowPath.addLine(to: CGPoint(x: insetRect.origin.x, y: insetRect.origin.y + insetRect.height * 0.5))
        arrowPath.addLine(to: CGPoint(x: insetRect.origin.x + insetRect.width * 0.5, y: insetRect.origin.y + insetRect.height))
        UIColor(red: 175, green: 175, blue: 175).withAlphaComponent(buttonAlpha).setStroke()
        arrowPath.lineWidth = bounds.width * 0.05
        arrowPath.lineCapStyle = .round
        arrowPath.stroke()
    }
    
    override func awakeFromNib() {
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = layer.bounds.width * 0.5
    }

}
