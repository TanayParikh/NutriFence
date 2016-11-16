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
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var imageToAnalyze: UIImage!
    var vcType: NFMainTVCType!
    var tableContents: [AnyObject] = [] {
        didSet {
            if let _ = tableView {
                unhideAll()
                activityIndicator.stopAnimating()
                self.tableView.reloadData()
            }
        }
    }
    
    // MARK: - View controller life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        if vcType! == .result {
            hideAll()
            activityIndicator.startAnimating()
        }
        initializeController()
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
            if type == .selection {
                let cell = tableView.cellForRow(at: indexPath)!
                cell.accessoryType = .checkmark
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let type = vcType {
            if type == .selection {
                let cell = tableView.cellForRow(at: indexPath)!
                cell.accessoryType = .none
            }
        }
    }
    
    // MARK: - parsing analysis results
    
    // IMPLEMENT ME
    private func parseResult(_ result: NFResult) -> [NFIngredient]? {
        return nil
    }
    
    // MARK: - Update UI
    
    private func hideAll() {
        headerLabel.isHidden = true
        tableView.isHidden = true
        nextButton.isHidden = true
    }
    
    private func unhideAll() {
        headerLabel.isHidden = false
        tableView.isHidden = false
        nextButton.isHidden = false
    }
    
    // MARK: - Helpers
    
    private func setGradient(_ gradient: CAGradientLayer) {
        self.view.layer.insertSublayer(gradient, at: 0)
    }
    
    private func initializeController() {
        switch vcType! {
        case .selection:
            headerLabel.text = "Select diet:"
            setGradient(NFGradientColors.gradientInView(self.view, withColor: UIColor.purple))
        case .result:
            let queue = DispatchQueue(label: "com.nutrifence.background")
            // send image for analysis
            queue.async { [weak self] Void in
                if let result = NFClassificationFetcher.analyzeImage(self!.imageToAnalyze) {
                    DispatchQueue.main.async { [weak self] Void in
                        self!.tableContents = result.ingredients
                        switch result.safetyStatus {
                        case .safe:
                            self!.setGradient(NFGradientColors.gradientInView(self!.view, withColor: UIColor.green))
                        case .unsafe:
                            self!.setGradient(NFGradientColors.gradientInView(self!.view, withColor: UIColor.red))
                        }
                    }
                }
            }
        }
    }
}
