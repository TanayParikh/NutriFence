//
//  NFMainTableViewController.swift
//  NutriFence (iOS)
//
//  Created by Matthew Watt on 11/11/16.
//  Copyright © 2016 NutriFence. All rights reserved.
//

import UIKit

class NFMainTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - Properties and instance variables
    
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var requestDietButton: UIButton!
    
    
    var vcType: NFMainTVCType!
    var tableContents: [AnyObject] = []
    
    // MARK: - View controller life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        switch vcType! {
        case .selection:
            setGradient(NFGradientColors.gradientInView(self.view, withColor: UIColor.purple))
            self.headerLabel.text = "Select diet:"
        case .result(let status):
            if status == .safe {
                setGradient(NFGradientColors.gradientInView(self.view, withColor: UIColor.green))
                self.headerLabel.text = "This product is safe to eat!"
            } else {
                setGradient(NFGradientColors.gradientInView(self.view, withColor: UIColor.red))
                self.headerLabel.text = "This product is NOT safe to eat!"
            }
        }
    }
    
    // MARK: - Actions
    
    @IBAction func requestDietButtonTapped(_ sender: UIButton) {
        let email = "nutrifencecanada@gmail.com"
        let url = URL(string: "mailto:\(email)")!
        UIApplication.shared.openURL(url)
    }
    
    
    // MARK: - Segues
    
    @IBAction func unwind(_ segue: UIStoryboardSegue) {
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
        cell.textLabel?.font = UIFont(name: "Century Gothic", size: 17)
        cell.textLabel?.textColor = UIColor(red: 175, green: 175, blue: 175)
        if let cellContent = tableContents[indexPath.row] as? NFIngredient {
            cell.textLabel?.text = cellContent.name
        } else if let cellContent = tableContents[indexPath.row] as? NFDiet {
            cell.textLabel?.text = cellContent.name
        }
        cell.selectionStyle = .none
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
    
}
