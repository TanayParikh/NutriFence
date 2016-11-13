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
    var imageToAnalyze: UIImage!
    var vcType: NFMainTVCType!
    private var tableContents: [AnyObject]! {
        didSet {
            tableView.reloadData()
            // stopAnimating()
        }
    }
    
    
    // MARK: - View controller life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        // startAnimating()
        initializeController()
    }
    
    
    // MARK: - Table view data source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableContents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    // MARK: - Table view delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let type = vcType {
            if type == .selection {
                
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let type = vcType {
            if type == .selection {
                
            }
        }
    }
    
    // MARK: - parsing analysis results
    
    // IMPLEMENT ME
    private func parseResult(_ result: NFResult) -> [NFIngredient]? {
        return nil
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
            // load table with
        case .result:
            let queue = DispatchQueue(label: "com.nutrifence.background")
            // send image for analysis
            queue.async { [weak self] Void in
                if let result = NFClassificationFetcher.analyzeImage(self!.imageToAnalyze) {
                    self!.tableContents = result.ingredients
                }
            }
        }
    }
}
