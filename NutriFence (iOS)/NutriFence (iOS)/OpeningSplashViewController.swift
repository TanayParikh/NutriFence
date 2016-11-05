//
//  OpeningSplashViewController.swift
//  NutriFence (iOS)
//
//  Created by Matthew Watt on 11/4/16.
//  Copyright © 2016 NutriFence. All rights reserved.
//

import UIKit

class OpeningSplashViewController: UIViewController {
    
    var backgroundGradient: CAGradientLayer!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        createGradientLayer()
    }
    
    func createGradientLayer() {
        backgroundGradient = CAGradientLayer()
        backgroundGradient.frame = self.view.bounds
        let topColor = UIColor(red: 69, green: 58, blue: 73).cgColor
        let bottomColor = UIColor(red: 62, green: 58, blue: 73).cgColor
        backgroundGradient.colors = [topColor, bottomColor]
        self.view.layer.insertSublayer(backgroundGradient, at: 0)
    }
    
}
