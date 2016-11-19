//
//  NFImageSelectionViewController.swift
//  NutriFence (iOS)
//
//  Created by Matthew Watt on 11/5/16.
//  Copyright © 2016 NutriFence. All rights reserved.
//

import UIKit
import SwiftyJSON

@IBDesignable
class NFImageSelectionViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var takePictureButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var chooseFromLibraryButton: UIButton!
    
    private var loadingOverlay = UIView()
    private var activityIndicator = UIActivityIndicatorView()
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
        debugPrint(#function)
        self.setGradient(NFGradientColors.gradientInView(self.view, withColor: UIColor.purple))
        customizeButtons()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        debugPrint(#function)
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
                }
            }
        }
    }
    
    // MARK: - UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerEditedImage] as? UIImage
        dismiss(animated: true, completion: nil)
        showOverlay()
        NFClassificationFetcher.analyzeImage(image!, completion: parseJSONResult)
    }
    
    // MARK: - Loading overlay
    
    private func showOverlay() {
        print(#function)
        loadingOverlay.frame = view.frame
        loadingOverlay.center = view.center
        loadingOverlay.layer.addSublayer(NFGradientColors.gradientInView(loadingOverlay, withColor: UIColor.purple))
        loadingOverlay.clipsToBounds = true
        
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        activityIndicator.activityIndicatorViewStyle = .gray
        activityIndicator.center = CGPoint(x: loadingOverlay.bounds.width / 2, y: loadingOverlay.bounds.height / 2)
        activityIndicator.color = UIColor(red: 175, green: 175, blue: 175)
        
//        let loadingLabel = UILabel()
//        loadingLabel.text = "Loading..."
//        loadingLabel.sizeToFit()
//        loadingLabel.textColor = UIColor(red: 175, green: 175, blue: 175)
        
        loadingOverlay.addSubview(activityIndicator)
        
        UIView.transition(with: self.view,
                          duration: 0.5,
                          options: .transitionCrossDissolve,
                          animations: { [weak self] Void in
                                self!.view.addSubview(self!.loadingOverlay)
                        },
                          completion: nil)
        activityIndicator.startAnimating()
        
        /* if #available(iOS 9.0, *) {
            loadingLabel.topAnchor.constraint(equalTo: activityIndicator.bottomAnchor).isActive = true
            loadingLabel.centerXAnchor.constraint(equalTo: loadingOverlay.centerXAnchor).isActive = true
        } else {
            // Fallback on earlier versions
        } */
    }
    
    private func hideOverlay() {
        UIView.transition(with: loadingOverlay,
                          duration: 0.5, options: .transitionCrossDissolve,
                          animations: { [weak self] Void in
                            self!.loadingOverlay.removeFromSuperview()
                        },
                          completion: nil)
        activityIndicator.stopAnimating()
        loadingOverlay.removeFromSuperview()
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
}
