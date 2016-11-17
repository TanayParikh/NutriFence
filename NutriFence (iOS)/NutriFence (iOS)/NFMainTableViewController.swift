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
    @IBOutlet weak var dividerLineView: UIView!
    
    var imageToAnalyze: UIImage!
    var vcType: NFMainTVCType!
    var tableContents: [AnyObject] = [] {
        didSet {
            if let _ = tableView {
                if case .result(let status) = vcType! {
                    switch status! {
                    case .safe:
                        setGradient(NFGradientColors.gradientInView(self.view, withColor: UIColor.green))
                        headerLabel.text = "This product is safe to eat!"
                    case .unsafe:
                        headerLabel.text = "This product is NOT safe to eat!"
                        setGradient(NFGradientColors.gradientInView(self.view, withColor: UIColor.red))
                    }
                }
                self.tableView.reloadData()
                unhideAll()
                activityIndicator.stopAnimating()
            }
        }
    }
    
    // MARK: - View controller life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setGradient(NFGradientColors.gradientInView(self.view, withColor: UIColor.purple))
        switch vcType! {
        case .selection:
            headerLabel.text = "Select diet:"
        case .result(_):
            hideAll()
            fetchResult(completion: setResult)
            activityIndicator.startAnimating()
        }
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
    
    
    private func fetchResult(completion: @escaping (NFResult) -> Void) {
        let queue = DispatchQueue(label: "com.nutrifence.background")
        // send image for analysis
        queue.async { [weak self] Void in
            if let result = NFClassificationFetcher.analyzeImage(self!.imageToAnalyze) {
                DispatchQueue.main.async {
                    print("Completion should execute")
                    completion(result)
                }
            }
        }
    }
    
    // Fetch callback func
    private func setResult(_ result: NFResult) {
        tableContents = result.ingredients
    }
}
