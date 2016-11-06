//
//  OpeningSplashViewController.swift
//  NutriFence (iOS)
//
//  Created by Matthew Watt on 11/4/16.
//  Copyright © 2016 NutriFence. All rights reserved.
//

import UIKit

@IBDesignable
class OpeningSplashViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private var backgroundGradient: CAGradientLayer!
    @IBInspectable var gradientTopColor: UIColor!
    @IBInspectable var gradientBottomColor: UIColor!
    @IBOutlet weak var selectionTableView: UITableView!
    @IBOutlet weak var nextArrowButton: UIButton!
    
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
        selectionTableView.delegate = self
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        createGradientLayer(top: gradientTopColor, bottom: gradientBottomColor)
    }
    
    @IBAction func scanArrowButtonTapped(_ sender: UIButton) {
        print(#function)
    }
    
    @IBAction func unwindToSplash(_ segue: UIStoryboardSegue) {
        
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
        cell?.selectionStyle = .none
        return cell!
    }
    
    
    // Table view delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)!
        cell.accessoryType = .checkmark
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)!
        cell.accessoryType = .none
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
