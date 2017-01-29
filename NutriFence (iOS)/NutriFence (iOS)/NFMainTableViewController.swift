//
//  NFMainTableViewController.swift
//  NutriFence (iOS)
//
//  Created by Matthew Watt on 11/11/16.
//  Copyright © 2016 NutriFence. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import SwiftyJSON

class NFMainTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - Properties and instance variables
    
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var requestDietButton: UIButton!
    @IBOutlet var dividerLines: [UIView]!
    @IBOutlet weak var ingredientsFoundHeaderLabel: UILabel!
    @IBOutlet weak var headerHeightConstraint: NSLayoutConstraint!
    
    // Useful constants
    private let iphone4sScreenHeight: CGFloat = 480.0
    
    
    var vcType: NFMainTVCType!
    var tableContents: [AnyObject] = []
    
    // MARK: - View controller life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI(vcType)
    }
    
    private func initUI(_ type: NFMainTVCType) {
        
        self.headerLabel.textColor = NFColors.text
        
        // Check whether we're displaying the choice list or the results
        switch type {
        case .selection:
            self.view.layer.insertSublayer(NFColors.gradient(self.view, color: NFColors.GradientColor.purple), at: 0)
            self.headerLabel.text = "Select diet:"
        case .result(let status):
            // Check whether the result was safe or unsafe
            switch status! {
            case .safe:
                self.view.layer.insertSublayer(NFColors.gradient(self.view, color: NFColors.GradientColor.green), at: 0)
                self.headerLabel.text = "This product is safe to eat!"
                break
            case .unsafe:
                self.view.layer.insertSublayer(NFColors.gradient(self.view, color: NFColors.GradientColor.red), at: 0)
                self.headerLabel.text = "This product is NOT safe to eat!"
                break
            }
            self.headerLabel.sizeToFit()
            self.ingredientsFoundHeaderLabel.text = "List of ingredients found:"
            self.ingredientsFoundHeaderLabel.sizeToFit()
            break
        }
        
        if let _ = headerHeightConstraint {
            if UIScreen.main.bounds.height <= iphone4sScreenHeight {
                headerHeightConstraint.constant = 30
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // MARK: - Actions
    
    @IBAction func requestDietButtonTapped(_ sender: UIButton) {
        let email = "nutrifencecanada@gmail.com"
        let url = URL(string: "mailto:\(email)?subject=Diet%20Addition%20Request")!
        UIApplication.shared.openURL(url)
    }
    
    
    @IBAction func nextButtonTapped() {
    }
    
    
    // MARK: - Segues
    
    @IBAction func unwind(_ segue: UIStoryboardSegue) {
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "LoadResultsSegue" {
            // Prepare the VC
            if let resultVC = segue.destination as? NFMainTableViewController {
                if let result = sender as? NFResult {
                    let resultColor = (result.safetyStatus == .safe ? UIColor.green : UIColor.red)
                    resultVC.vcType = NFMainTVCType.result(result.safetyStatus)
                    resultVC.setGradient(NFGradientColors.gradientInView(resultVC.view, withColor: resultColor))
                    resultVC.tableContents = result.ingredients
                    self.hideOverlay()
                }
            }
        }
    }
    
    // MARK: - Table view data source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableContents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var identifier = ""
        switch vcType! {
        case .result:
            identifier = "IngredientCell"
        case .selection:
            identifier = "SelectionCell"
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier)!
//        cell.textLabel?.font = UIFont(name: "Century Gothic", size: 17)
//        cell.textLabel?.textColor = UIColor(red: 175, green: 175, blue: 175)
//        if let cellContent = tableContents[indexPath.row] as? NFIngredient {
//            cell.textLabel?.text = cellContent.name
//        } else if let cellContent = tableContents[indexPath.row] as? NFDiet {
//            cell.textLabel?.text = cellContent.name
//        }
        cell.selectionStyle = .none
        cell.textLabel?.lineBreakMode = .byWordWrapping
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        return cell
    }
    
    // MARK: - Table view delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let type = vcType {
            switch type {
            case .selection:
                let cell = tableView.cellForRow(at: indexPath)!
                cell.accessoryType = .checkmark
            case .result(_):
                break
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let type = vcType {
            switch type {
            case .selection:
                let cell = tableView.cellForRow(at: indexPath)!
                cell.accessoryType = .none
            case .result(_):
                break
            }
        }
    }
    
    // MARK: - Helpers
    
    func setGradient(_ gradient: CAGradientLayer) {
        self.view.layer.insertSublayer(gradient, at: 0)
    }
    
    private func setCustomLinesColor() {
        for lineView in self.dividerLines {
            lineView.backgroundColor = UIColor(red: 175, green: 175, blue: 175)
        }
    }
    
}
