//
//  NFLabelCaptureViewController.swift
//  NutriFence (iOS)
//
//  Created by Matthew Watt on 12/18/16.
//  Copyright © 2016 NutriFence. All rights reserved.
//

import UIKit
import CameraManager

class NFLabelCaptureViewController: UIViewController, TOCropViewControllerDelegate {
    
    
    @IBOutlet weak var cameraView: UIView!
    private let cameraManager = CameraManager()
    @IBOutlet weak var shutterButton: NFShutterButton!
    
    private var croppedImage: UIImage! {
        didSet {
            // go back to previous controller
            print("Image set")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
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
        cameraManager.resumeCaptureSession()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        cameraManager.stopCaptureSession()
    }
    
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
    
    fileprivate func displayCropViewController(with image: UIImage) {
        let cropController = TOCropViewController(croppingStyle: TOCropViewCroppingStyle.default, image: image)
        cropController.delegate = self
        present(cropController, animated: true, completion: nil)
    }
    
    fileprivate func addCameraToView() {
        cameraManager.addPreviewLayerToView(cameraView, newCameraOutputMode: .stillImage)
        cameraManager.showErrorBlock = { [weak self] (erTitle: String, erMessage: String) -> Void in
            
            let alertController = UIAlertController(title: erTitle, message: erMessage, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (alertAction) -> Void in  }))
            
            self?.present(alertController, animated: true, completion: nil)
        }
    }
    
    // MARK: - TOCropViewControllerDelegate
    
    func cropViewController(_ cropViewController: TOCropViewController, didCropTo image: UIImage, with cropRect: CGRect, angle: Int) {
        self.croppedImage = image
    }
}
