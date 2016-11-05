//
//  OpeningSplashViewController.swift
//  NutriFence (iOS)
//
//  Created by Matthew Watt on 11/4/16.
//  Copyright © 2016 NutriFence. All rights reserved.
//

import UIKit

@IBDesignable
class OpeningSplashViewController: UIViewController, UITableViewDataSource {
    
    private var backgroundGradient: CAGradientLayer!
    @IBInspectable var gradientTopColor: UIColor!
    @IBInspectable var gradientBottomColor: UIColor!
    @IBOutlet weak var selectionTableView: UITableView!
    static let rgbGrayFontColor = 234
    let selections = [
        "Lactose Intolerant",
        "Gluten Free",
        "Vegan",
        "Peanut Allergic"
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        selectionTableView.dataSource = self
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        createGradientLayer(top: gradientTopColor, bottom: gradientBottomColor)
    }
    
    // Data source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return selections.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let selection = selections[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "SelectionCell")
        cell?.textLabel?.font = UIFont(name: "Century Gothic", size: 17)
        cell?.textLabel?.textColor = OpeningSplashViewController.customGray()
        cell?.textLabel?.text = selection
        cell?.indentationLevel = 0
        cell?.preservesSuperviewLayoutMargins = false
        cell?.layoutMargins = UIEdgeInsets.zero
        return cell!
    }
    
    // Custom drawing
    
    func createGradientLayer(top: UIColor, bottom: UIColor) {
        backgroundGradient = CAGradientLayer()
        backgroundGradient.frame = self.view.bounds
        backgroundGradient.colors = [top.cgColor, bottom.cgColor]
        self.view.layer.insertSublayer(backgroundGradient, at: 0)
    }
    
    // Helpers
    
    static func customGray() -> UIColor {
        return UIColor(red: rgbGrayFontColor, green: rgbGrayFontColor, blue: rgbGrayFontColor)
    }
}
