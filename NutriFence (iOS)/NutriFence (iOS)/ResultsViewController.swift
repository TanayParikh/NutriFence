//
//  ResultsViewController.swift
//  NutriFence (iOS)
//
//  Created by Matthew Watt on 11/5/16.
//  Copyright © 2016 NutriFence. All rights reserved.
//

import UIKit
import SwiftyJSON

class ResultsViewController: UIViewController, UITableViewDataSource, UIGestureRecognizerDelegate {
    
    
    var isSafe: Bool!
    var ingredients: [String]!
    @IBOutlet weak var scanNewButton: UIButton!
    @IBOutlet var swipeGestureRecognizer: UISwipeGestureRecognizer!
    
    
    // Gradient
    private var backgroundGradient: CAGradientLayer!
    var redTopColor = UIColor(red: 83, green: 38, blue: 38)
    var redBottomColor = UIColor(red: 83, green: 38, blue: 38)
    var greenTopColor = UIColor(red: 40, green: 64, blue: 40)
    var greenBottomColor = UIColor(red: 40, green: 48, blue: 40)
    
    @IBOutlet weak var ingredientsTableView: UITableView!
    @IBOutlet weak var safetyResultsLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        ingredientsTableView.dataSource = self
        configureLayout()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ingredientsTableView.reloadData()
    }
    
    // Actions
    
    @IBAction func swipeGestureRecognized(_ sender: UISwipeGestureRecognizer) {
        scanNewButton.sendActions(for: .touchUpInside)
    }
    
    // Gesture Recognizer delegate
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.location(in: self.view).x < self.view.bounds.width / 3 {
            return true
        }
        else {
            return false
        }
    }
    
    
    // Data source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ingredients.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let ingredient = ingredients[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "IngredientCell")
        cell?.textLabel?.font = UIFont(name: "Century Gothic", size: 17)
        cell?.textLabel?.textColor = OpeningSplashViewController.customGray()
        cell?.textLabel?.text = ingredient
        return cell!
    }
    
    // UI
    
    func createGradientLayer(top: UIColor, bottom: UIColor) {
        backgroundGradient = CAGradientLayer()
        backgroundGradient.frame = self.view.bounds
        backgroundGradient.colors = [top.cgColor, bottom.cgColor]
        self.view.layer.insertSublayer(backgroundGradient, at: 0)
    }
    
    func configureLayout() {
        createGradientLayer(top: (isSafe! ? greenTopColor : redTopColor), bottom: (isSafe! ? greenBottomColor : redBottomColor))
        safetyResultsLabel.text = "This product \(isSafe! ? "is": "is NOT") safe to consume"
        ingredientsTableView.reloadData()
    }
}
