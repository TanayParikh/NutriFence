//
//  NFLabelCaptureViewController.swift
//  NutriFence (iOS)
//
//  Created by Matthew Watt on 12/18/16.
//  Copyright © 2016 NutriFence. All rights reserved.
//

import UIKit
import CameraManager
import TOCropViewController
import SwiftyJSON
import NVActivityIndicatorView

class NFLabelCaptureViewController: UIViewController, TOCropViewControllerDelegate {
    
    // MARK: - Instance variables
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    
    @IBOutlet weak var cameraView: UIView!
    fileprivate let cameraManager = CameraManager()
    @IBOutlet weak var shutterButton: NFShutterButton!
    
    private var croppedImage: UIImage! {
        didSet {
            analyzeImage(croppedImage)
        }
    }
    
    
    // MARK: - View controller

    override func viewDidLoad() {
        super.viewDidLoad()
        cameraManager.writeFilesToPhoneLibrary = false
        navigationController?.isNavigationBarHidden = true
        switch cameraManager.currentCameraStatus() {
        case .notDetermined:
            cameraManager.askUserForCameraPermission({ [unowned self] (isGranted) in
                if isGranted {
                    self.addCameraToView()
                }
            })
        case .accessDenied:
            cameraManager.showErrorBlock("Permission needed", "NutriFence needs access to the camera to function. Go to settings to enable camera access")
        case .noDeviceFound: break
        case .ready:
            addCameraToView()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.setStatusBarHidden(true, with: .none)
        cameraManager.resumeCaptureSession()
        print(#function)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        cameraManager.stopCaptureSession()
    }
    
    // MARK: - Actions
    
    @IBAction func shutterButtonTapped() {
        cameraManager.capturePictureWithCompletion({ [unowned self] (image, error) -> Void in
            if let errorOccured = error {
                self.cameraManager.showErrorBlock("Error occurred", errorOccured.localizedDescription)
            }
            else if let image = image {
                self.displayCropViewController(with: image)
            }
        })
    }
    
    
    // MARK: - Helpers
    
    fileprivate func displayCropViewController(with image: UIImage) {
        let cropController = TOCropViewController(croppingStyle: TOCropViewCroppingStyle.default, image: image)
        cropController.delegate = self
        present(cropController, animated: true, completion: nil)
    }
    
    fileprivate func addCameraToView() {
        let _ = cameraManager.addPreviewLayerToView(cameraView, newCameraOutputMode: .stillImage)
        cameraManager.showErrorBlock = { [weak self] (erTitle: String, erMessage: String) -> Void in
            
            let alertController = UIAlertController(title: erTitle, message: erMessage, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (alertAction) -> Void in  }))
            
            self?.present(alertController, animated: true, completion: nil)
        }
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
                    cameraManager.stopCaptureSession()
                }
            }
        }
    }
    
    @IBAction func unwind(_ segue: UIStoryboardSegue) {
    }
    
    // MARK: - TOCropViewControllerDelegate
    
    func cropViewController(_ cropViewController: TOCropViewController, didCropTo image: UIImage, with cropRect: CGRect, angle: Int) {
        self.croppedImage = image
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - Image analysis
extension NFLabelCaptureViewController {
    fileprivate func analyzeImage(_ image: UIImage) {
        showOverlay()
        NFClassificationFetcher.analyzeImage(image, onSuccess: parseJSONResult, onFail: displayErrorAlert)
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
        hideOverlay()
        performSegue(withIdentifier: "LoadResultsSegue", sender: result)
    }
    
    func displayErrorAlert() {
        let message = "Looks like we're having some trouble connecting. Check your connection and try again."
        let errorAlert = UIAlertController(title: "Connection error",
                                           message: message,
                                           preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: { [unowned self] (_) -> Void in
            self.dismiss(animated: true, completion: nil)
        })
        errorAlert.addAction(okAction)
        hideOverlay()
        present(errorAlert, animated: true, completion: { [unowned self] Void in
            self.cameraManager.stopCaptureSession()
        })
    }
    
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
    }
}
