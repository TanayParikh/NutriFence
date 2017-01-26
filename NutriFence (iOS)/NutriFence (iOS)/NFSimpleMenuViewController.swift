//
//  NFSimpleMenuViewController.swift
//  NutriFence (iOS)
//
//  Created by Matthew Watt on 12/19/16.
//  Copyright © 2016 NutriFence. All rights reserved.
//

import UIKit

class NFSimpleMenuViewController: UIViewController {
    
    /**
     This view controller should only show portrait
     */
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.layer.insertSublayer(NFGradientColors.gradientInView(self.view, withColor: UIColor.purple), at: 0)
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    
    // MARK: - Actions
    
    /**
     Action called when a user swipes right
     - parameters:
        -sender: the swipe gesture recognizer that recognized the swipe
     */
    @IBAction func userDidSwipe(_ sender: UISwipeGestureRecognizer) {
        performSegue(withIdentifier: "CaptureLabelSegue", sender: nil)
    }
    
    /**
     Action used to perform an unwind segue from descendent view controllers to this one
     - parameters:
        - segue: the triggered segue
     */
    @IBAction func unwind(_ segue: UIStoryboardSegue) {
    }
    
    /**
     Action that triggers the segue to show the tutorial
     */
    @IBAction func showTutorial() {
        performSegue(withIdentifier: "ShowTutorialSegue", sender: nil)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // Debugging
    
    deinit {
        print("NFSimpleMenuController destroyed")
    }

}
