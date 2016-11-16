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
    
    
    @IBInspectable var color: NFGradientColors!
    
    private var imagePicker = UIImagePickerController()

    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        // Do any additional setup after loading the view.

        self.setGradient(NFGradientColors.gradientInView(self.view, withColor: UIColor.purple))
        customizeButtons()
    }
    
    // MARK: - Actions
    
    @IBAction func takePictureButtonTapped(_ sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.sourceType = .camera
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    @IBAction func chooseFromLibraryButtonTapped(_ sender: UIButton) {
        print(#function)
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    
    // MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "LoadResultsSegue" {
            // Prepare the VC
            if let imageToAnalyze = sender as? UIImage {
                if let resultVC = segue.destination as? NFMainTableViewController {
                    resultVC.imageToAnalyze = imageToAnalyze
                    resultVC.vcType = .result
                }
            }
        }
    }
    
    // MARK: - UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerEditedImage] as? UIImage
        performSegue(withIdentifier: "LoadResultsSegue", sender: image!)
        dismiss(animated: true, completion: nil)
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
}
