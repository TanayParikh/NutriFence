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
import ALCameraViewController
import Photos

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
        self.headerLabel.textColor = UIColor(red: 175, green: 175, blue: 175)
        
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
            self.headerLabel.sizeToFit()
            self.ingredientsFoundHeaderLabel.text = "List of ingredients found:"
            self.ingredientsFoundHeaderLabel.sizeToFit()
        }
        if let _ = headerHeightConstraint {
            if UIScreen.main.bounds.height <= iphone4sScreenHeight {
                headerHeightConstraint.constant = 30
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        unhideSubviews()
        NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
    }
    
    // MARK: - Actions
    
    @IBAction func requestDietButtonTapped(_ sender: UIButton) {
        let email = "nutrifencecanada@gmail.com"
        let url = URL(string: "mailto:\(email)")!
        UIApplication.shared.openURL(url)
    }
    
    
    @IBAction func nextButtonTapped() {
        let cameraController = CameraViewController(croppingEnabled: true,
                                                    allowsLibraryAccess: true,
                                                    completion: { [weak self] (image, _) -> Void in
                                                        if let imageData = image {
                                                            NFClassificationFetcher.analyzeImage(imageData,
                                                                                                 onSuccess: self!.parseJSONResult,
                                                                                                 onFail: self!.displayErrorAlert)
                                                        }
                                                        self!.dismiss(animated: true, completion: { [weak self] Void in
                                                            self!.hideSubviews()
                                                            self!.showOverlay()
                                                        })
        })
        present(cameraController, animated: true, completion: nil)
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
        cell.textLabel?.font = UIFont(name: "Century Gothic", size: 17)
        cell.textLabel?.textColor = UIColor(red: 175, green: 175, blue: 175)
        if let cellContent = tableContents[indexPath.row] as? NFIngredient {
            cell.textLabel?.text = cellContent.name
        } else if let cellContent = tableContents[indexPath.row] as? NFDiet {
            cell.textLabel?.text = cellContent.name
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

// MARK: - Camera view and loading animation
extension NFMainTableViewController {
    // MARK: - Loading overlay
    
    fileprivate func hideOverlay() {
        NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
    }
    
    fileprivate func showOverlay() {
        let rectSize = CGSize(width: self.view.bounds.width * 0.2, height: self.view.bounds.width * 0.2)
        let activityData = ActivityData(size: rectSize,
                                        message: "Working...",
                                        type: NVActivityIndicatorType.ballBeat,
                                        color: UIColor(red: 175, green: 175, blue: 175),
                                        padding: nil,
                                        displayTimeThreshold: nil,
                                        minimumDisplayTime: 5)
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData)
        hideSubviews()
    }
    
    fileprivate func unhideSubviews() {
        for view in self.view.subviews {
            UIView.animate(withDuration: 0.2,
                           animations: {
                            view.isHidden = false
            })
        }
    }
    
    fileprivate func hideSubviews() {
        for view in self.view.subviews {
            if view.restorationIdentifier == "NFLogo" {
                continue
            } else {
                UIView.animate(withDuration: 0.2,
                               animations: {
                                view.isHidden = true
                })
            }
        }
    }
}

// MARK: - Networking and parsing results
extension NFMainTableViewController {
    func parseJSONResult(_ json: JSON) {
        var result = NFResult(safetyStatus: .unsafe, ingredients: [])
        var ingredients = [NFIngredient]()
        if let jsonDict = json.dictionary {
            debugPrint(jsonDict)
            let isSafe = jsonDict["isGlutenFree"]?.bool!
            if isSafe == true {
                result.safetyStatus = .safe
                if let ingreds = jsonDict["Good_Ingredients"]?.array {
                    for goodIngred in ingreds {
                        ingredients.append(NFIngredient(with: goodIngred.string!))
                    }
                }
            } else {
                print("Setting as .unsafe")
                result.safetyStatus = .unsafe
                if let ingreds = jsonDict["Bad_Ingredients"]?.array {
                    for badIngred in ingreds {
                        ingredients.append(NFIngredient(with: badIngred.string!))
                    }
                }
            }
            result.ingredients = ingredients
        }
        // After parsing, trigger segue to see results
        performSegue(withIdentifier: "LoadResultsSegue", sender: result)
    }
    
    func displayErrorAlert() {
        let message = "Looks like our servers are having some trouble right now. Try again in a little while!"
        let errorAlert = UIAlertController(title: "Connection error",
                                           message: message,
                                           preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        errorAlert.addAction(okAction)
        unhideSubviews()
        present(errorAlert, animated: true, completion: { [weak self] Void in
            self!.hideOverlay()
        })
    }
}
