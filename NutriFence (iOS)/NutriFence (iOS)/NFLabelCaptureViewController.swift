//
//  NFLabelCaptureViewController.swift
//  NutriFence (iOS)
//
//  Created by Matthew Watt on 12/18/16.
//  Copyright © 2016 NutriFence. All rights reserved.
//

import UIKit
import CameraManager

class NFLabelCaptureViewController: UIViewController {
    
    
    @IBOutlet weak var cameraView: UIView!
    private let cameraManager = CameraManager()
    @IBOutlet weak var shutterButton: NFShutterButton!

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
        
    }
    
    @IBAction func shutterButtonTapped() {
        
    }
    
    fileprivate func addCameraToView() {
        cameraManager.addPreviewLayerToView(cameraView, newCameraOutputMode: .stillImage)
        cameraManager.showErrorBlock = { [weak self] (erTitle: String, erMessage: String) -> Void in
            
            let alertController = UIAlertController(title: erTitle, message: erMessage, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (alertAction) -> Void in  }))
            
            self?.present(alertController, animated: true, completion: nil)
        }
    }
}
