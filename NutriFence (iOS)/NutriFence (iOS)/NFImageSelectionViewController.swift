//
//  NFImageSelectionViewController.swift
//  NutriFence (iOS)
//
//  Created by Matthew Watt on 11/5/16.
//  Copyright © 2016 NutriFence. All rights reserved.
//

import UIKit
import SwiftyJSON
import NVActivityIndicatorView

class NFImageSelectionViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, NVActivityIndicatorViewable {

    @IBOutlet weak var takePictureButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var chooseFromLibraryButton: UIButton!
    
    private var loadingOverlay: NVActivityIndicatorView!
    private var activityIndicator = UIActivityIndicatorView()
    private var isAnimating = false
    private var result: NFResult? {
        didSet {
            performSegue(withIdentifier: "LoadResultsSegue", sender: self.result!)
        }
    }
    private var imagePicker = UIImagePickerController()
    
    // MARK: - View controller life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        // Do any additional setup after loading the view.
        self.setGradient(NFGradientColors.gradientInView(self.view, withColor: UIColor.purple))
        customizeButtons()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // MARK: - Actions
    
    @IBAction func takePictureButtonTapped(_ sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.sourceType = .camera
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    @IBAction func chooseFromLibraryButtonTapped(_ sender: UIButton) {
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    
    // MARK: - Segues
    
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
    
    // MARK: - UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerEditedImage] as? UIImage
        dismiss(animated: true, completion: nil)
        showOverlay()
        NFClassificationFetcher.analyzeImage(image!, onSuccess: parseJSONResult, onFail: displayErrorAlert)
    }
    
    // MARK: - Loading overlay
    
    private func hideOverlay() {
        NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
    }
    
    private func showOverlay() {
        let rectSize = CGSize(width: self.view.bounds.width * 0.2, height: self.view.bounds.width * 0.2)
        let activityData = ActivityData(size: rectSize,
                                        message: "Analyzing...",
                                        type: NVActivityIndicatorType.ballBeat,
                                        color: UIColor(red: 175, green: 175, blue: 175),
                                        padding: nil,
                                        displayTimeThreshold: nil,
                                        minimumDisplayTime: 5)
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData)
        hideSubviews()
    }
    
    private func hideSubviews() {
        for view in self.view.subviews {
            if view.restorationIdentifier == "NFLogo" {
                continue
            } else {
                view.isHidden = true
            }
        }
    }
    
    private func unhideSubviews() {
        for view in self.view.subviews {
            view.isHidden = false
        }
    }
    
    
    // MARK: - Helpers
    
    private func setGradient(_ gradient: CAGradientLayer) {
        self.view.layer.insertSublayer(gradient, at: 0)
    }
    
    private func customizeButtons() {
        let gray = UIColor(red: 175, green: 175, blue: 175)
        self.takePictureButton.layer.borderWidth = 1.5
        self.takePictureButton.layer.borderColor = gray.cgColor
        self.chooseFromLibraryButton.layer.borderWidth = 1.5
        self.chooseFromLibraryButton.layer.borderColor = gray.cgColor
    }
    
    // MARK: - Network callbacks
    
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
        self.result = result
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
