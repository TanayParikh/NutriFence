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
    
    /**
     A capture view controller only supports portrait capture
     */
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    
    @IBOutlet weak var cameraView: UIView!
    fileprivate let cameraManager = CameraManager()
    @IBOutlet weak var shutterButton: NFShutterButton!
    
    private var croppedImage: UIImage! {
        didSet {
            analyze(self.croppedImage)
        }
    }
    
    
    // MARK: - View controller

    /**
     Configure the view controller - sets up the camera manager for use
     If the user has never been asked for camera permission, this triggers an alert
     If the user disabled permission, an error is displayed
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        cameraManager.cameraOutputQuality = .medium
        cameraManager.writeFilesToPhoneLibrary = false
        navigationController?.isNavigationBarHidden = true
        switch cameraManager.currentCameraStatus() {
        case .notDetermined:
            cameraManager.askUserForCameraPermission({ [unowned self] (isGranted) in
                if isGranted {
                    self.addCameraToView()
                } else {
                    self.performSegue(withIdentifier: "NFNoPermissionUnwindSegue", sender: nil)
                }
            })
        case .accessDenied:
            cameraManager.showErrorBlock("Permission needed", "NutriFence needs access to the camera to function. Go to settings to enable camera access")
        case .noDeviceFound: break
        case .ready:
            addCameraToView()
        }
    }
    
    /**
     Checks if the user still has granted permission to use the camera
     */
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        switch cameraManager.currentCameraStatus() {
        case .accessDenied:
            let alertController = UIAlertController(title: "Camera permission needed",
                                                    message: "NutriFence needs access to the camera to work properly. Go to settings to enable camera permission.",
                                                    preferredStyle: .alert)
            let alertActionSettings = UIAlertAction(title: "Settings", style: .default, handler: { (_) in
                if let settingsURL = URL(string: UIApplicationOpenSettingsURLString) {
                    UIApplication.shared.openURL(settingsURL)
                }
            })
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { [unowned self] (_) in
                self.performSegue(withIdentifier: "NFNoPermissionUnwindSegue", sender: nil)
                self.dismiss(animated: true, completion: nil)
            })
            alertController.addAction(alertActionSettings)
            alertController.addAction(cancelAction)
            present(alertController, animated: true, completion: nil)
            return
        case .ready:
            cameraManager.resumeCaptureSession()
        case .noDeviceFound, .notDetermined:
            print("Error")
        }
        UIApplication.shared.setStatusBarHidden(true, with: .none)
    }
    
    /**
     Stops the camera session
     */
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        cameraManager.stopCaptureSession()
    }
    
    // MARK: - Actions
    
    /**
     Action to handle the tapping of the shutter button
     */
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
    
    /**
     This function configures and presents a crop view controller with an image captured by the camera
     - parameters:
        - image: The UIImage object taken from the camera
     */
    fileprivate func displayCropViewController(with image: UIImage) {
        let cropController = TOCropViewController(croppingStyle: TOCropViewCroppingStyle.default, image: image)
        cropController.delegate = self
        cropController.setAspectRatioPreset(.presetSquare, animated: false)
        present(cropController, animated: true, completion: nil)
    }
    
    /**
     Adds the camera preview layer to the view controller
     */
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
                    let resultColor = (result.safetyStatus == .safe ? NFColors.NFGradientColor.green : .red)
                    resultVC.vcType = NFMainTVCType.result(result.safetyStatus)
                    resultVC.setGradient(NFColors.gradient(resultVC.view, color: resultColor))
                    resultVC.tableContents = result.ingredients
                    cameraManager.stopCaptureSession()
                }
            }
        }
    }
    
    /**
     Unwind action used in StoryBoard to return to this view controller
     */
    @IBAction func unwind(_ segue: UIStoryboardSegue) {
    }
    
    // MARK: - TOCropViewControllerDelegate
    /**
     Implementation of CropViewController delegate. Sets the croppedImage property of ths view controller for processing
     */
    func cropViewController(_ cropViewController: TOCropViewController, didCropTo image: UIImage, with cropRect: CGRect, angle: Int) {
        self.croppedImage = image
        dismiss(animated: true, completion: nil)
    }
    
    fileprivate func analyze(_ image: UIImage) {
        NFClassificationFetcher.analyze((.celiac, image), completion: present)
    }
    
    fileprivate func present(_ result: NFResult) {
        // pass result back to presenting vc
    }
}

// FIXME: This code will eventually make its way to the main tvc controller
/**
 This extension encapsulates the image analysis logic
 */
extension NFLabelCaptureViewController {
    
    
    /**
     Used as a failure handler to the analyzeImage function of NFClassificationFetcher
     */
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
    
    /**
     Hides the Activity indicator currently presenting
     */
    fileprivate func hideOverlay() {
        NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
    }
    
    /**
     Shows an activity indicator when the image analysis begins
     */
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
