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
    private var backgroundGradient: CAGradientLayer!
    static let rgbGrayFontColor = 234
    
    struct ClassificationResult {
        var isSafe: Bool!
        var ingredients: [String]!
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        swipeGestureRecognizer.direction = .right
        swipeGestureRecognizer.numberOfTouchesRequired = 1
        swipeGestureRecognizer.delegate = self
        // Do any additional setup after loading the view.
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
        
    }
    
    // MARK: - UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        
        dismiss(animated: true, completion: nil)
    }
    
}
