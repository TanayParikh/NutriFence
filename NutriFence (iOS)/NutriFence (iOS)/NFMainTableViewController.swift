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

class NFMainTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NFCroppedImageHandlerDelegate {
    
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
    
    // Cropped Image Handler Delegate
    var croppedImage: UIImage?
    
    var vcType: NFMainTVCType!
    var tableContents: [AnyObject] = []
    var selectedDietIndex: Int?
    private var shouldPerformResultSegue: Bool?
    
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
        setCustomLinesColor()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let croppedImage = croppedImage {
            startAnimating()
            let data = (NFClassificationFetcher.Diet.list[selectedDietIndex!], croppedImage)
            NFClassificationFetcher.analyze(data, completion: { [unowned self] (result) in
                self.stopAnimating()
                self.croppedImage = nil
                if(result.error != nil) {
                    self.displayError()
                    print(result.error!.localizedDescription)
                } else {
                    self.performSegue(withIdentifier: "DisplayResultSegue", sender: result)
                }
            })
        }
    }
    
    // MARK: - Loading animations
    
    private func startAnimating() {
        let rectSize = CGSize(width: self.view.bounds.width * 0.2, height: self.view.bounds.width * 0.2)
        let activityData = ActivityData(size: rectSize,
                                        message: "Working...",
                                        type: NVActivityIndicatorType.ballBeat,
                                        color: NFColors.text,
                                        padding: nil,
                                        displayTimeThreshold: nil,
                                        minimumDisplayTime: 5)
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData)
    }
    
    private func stopAnimating() {
        NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
    }
    
    private func displayError() {
        let alertController = UIAlertController(title: "Server error",
                                                message: "There seems to be a problem with our servers right now. Try again in a little while",
                                                preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { [unowned self] (_) in
            self.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Actions
    
    @IBAction func requestDietButtonTapped(_ sender: UIButton) {
        let email = "nutrifencecanada@gmail.com"
        let url = URL(string: "mailto:\(email)?subject=Diet%20Addition%20Request")!
        UIApplication.shared.openURL(url)
    }
    
    
    @IBAction func nextButtonTapped() {
        performSegue(withIdentifier: "CaptureLabelSegue", sender: nil)
    }
    
    
    // MARK: - Segues
    @IBAction func unwind(_ segue: UIStoryboardSegue) {
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
        case "CaptureLabelSegue":
            if let destVC = segue.destination as? NFLabelCaptureViewController {
                destVC.imageHandlerDelegate = self
            }
            break
        case "DisplayResultSegue":
            if let destVC = segue.destination as? NFMainTableViewController, let result = sender as? NFClassificationFetcher.Result {
                if let ingredients = result.ingredients, let status = result.safetyStatus {
                    destVC.vcType = .result(status)
                    destVC.tableContents = ingredients as [AnyObject]
                }
            }
            break
        default:
            break
        }
    }
    
    // MARK: - Table view data source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableContents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(selectedDietIndex == nil) {
            selectedDietIndex = 0
            tableView.selectRow(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: .none)
        }
        
        var identifier = ""
        switch vcType! {
        case .result:
            identifier = "IngredientCell"
        case .selection:
            identifier = "SelectionCell"
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier)!
        cell.textLabel?.font = UIFont(name: "Century Gothic", size: 17)
        cell.textLabel?.textColor = NFColors.text
        if let cellContent = tableContents[indexPath.row] as? NFClassificationFetcher.Ingredient {
            cell.textLabel?.text = cellContent.name
        } else if let cellContent = tableContents[indexPath.row] as? NFClassificationFetcher.Diet {
            cell.textLabel?.text = cellContent.displayString
        }
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
    
    private func setCustomLinesColor() {
        for lineView in self.dividerLines {
            lineView.backgroundColor = NFColors.text
        }
    }
    
}
