//
//  NFTutorialViewController.swift
//  NutriFence (iOS)
//
//  Created by Matthew Watt on 12/20/16.
//  Copyright © 2016 NutriFence. All rights reserved.
//

import UIKit
import EAIntroView

class NFTutorialViewController: UIViewController, EAIntroDelegate {
    
    // MARK: - Intro strings
    
    private let pageWelcomeTitle = "Welcome to NutriFence!"
    private let pageWelcomeDesc = "We think you're going to love using NutriFence. Let us show you how it works"
    
    private let page1Title = "Snap your label"
    private let page1Desc = "Use your iPhone's camera to snap a photo of the ingredient label you want to analyze"
    
    private let page2Title = "Crop"
    private let page2Desc = "Crop the label so NutriFence can give you the best results"
    
    private let page3Title = "Sit back and relax"
    private let page3Desc = "Tap done and let NutriFence do the hard work"
    
    private let page4Title = "Results...fast!"
    private let page4Desc = "Within seconds, NutriFence has an answer. Simple!"
    
    private var topInset: CGFloat!

    override func viewDidLoad() {
        super.viewDidLoad()
        topInset = view.bounds.height * 0.05
        // Do any additional setup after loading the view.
        showIntroWithCustomPages()
        
    }
    
    func showIntroWithCustomPages() {
        
        let imageFrame = CGRect(x: 0, y: 0, width: self.view.bounds.size.width - topInset, height: self.view.bounds.size.width - topInset)
        
        let pageWelcome = EAIntroPage()
        pageWelcome.title = pageWelcomeTitle
        pageWelcome.titleFont = UIFont(name: "Century Gothic", size: 18)
        pageWelcome.desc = pageWelcomeDesc
        pageWelcome.descFont = UIFont(name: "Century Gothic", size: 15)
        pageWelcome.titleIconView = UIImageView(image: UIImage(named: "Logo"))
        
        // Init pages and IntroView
        let page1 = EAIntroPage()
        page1.title = page1Title
        page1.titleFont = UIFont(name: "Century Gothic", size: 18)
        page1.desc = page1Desc
        page1.descFont = UIFont(name: "Century Gothic", size: 15)
        let page1ImageView = UIImageView(frame: imageFrame)
        page1ImageView.image = UIImage(named: "CapturePreview")
        page1ImageView.contentMode = .scaleAspectFill
        page1.titleIconView = page1ImageView
        
        
        let page2 = EAIntroPage()
        page2.title = page2Title
        page2.titleFont = UIFont(name: "Century Gothic", size: 18)
        page2.desc = page2Desc
        page2.descFont = UIFont(name: "Century Gothic", size: 15)
        let page2ImageView = UIImageView(frame: imageFrame)
        page2ImageView.image = UIImage(named: "CropPreview")
        page2ImageView.contentMode = .scaleAspectFit
        page2.titleIconView = page2ImageView
        
        
        let page3 = EAIntroPage()
        page3.title = page3Title
        page3.titleFont = UIFont(name: "Century Gothic", size: 18)
        page3.desc = page3Desc
        page3.descFont = UIFont(name: "Century Gothic", size: 15)
        let page3ImageView = UIImageView(frame: imageFrame)
        page3ImageView.image = UIImage(named: "WorkingPreview")
        page3ImageView.contentMode = .scaleAspectFit
        page3.titleIconView = page3ImageView
        
        let page4 = EAIntroPage()
        page4.title = page4Title
        page4.titleFont = UIFont(name: "Century Gothic", size: 18)
        page4.desc = page4Desc
        page4.descFont = UIFont(name: "Century Gothic", size: 15)
        let page4ImageView = UIImageView(frame: imageFrame)
        page4ImageView.image = UIImage(named: "SafeResult")
        page4ImageView.contentMode = .scaleAspectFit
        page4.titleIconView = page4ImageView
        
        let intro = EAIntroView(frame: self.view.frame, andPages: [pageWelcome, page1, page2, page3, page4])!
        intro.backgroundColor = UIColor(red: 69, green: 58, blue: 73)
        
        let btn = UIButton(type: .roundedRect)
        btn.frame = CGRect(x: 0, y: 0, width: 230, height: 40)
        btn.setTitle("Skip", for: .normal)
        btn.setTitleColor(UIColor.white, for: .normal)
        btn.titleLabel?.font = UIFont(name: "Century Gothic", size: 12)
        btn.layer.borderWidth = 2
        btn.layer.cornerRadius = 10
        btn.layer.borderColor = UIColor.white.cgColor
        intro.skipButton = btn
        
        // Position and align
        intro.skipButtonAlignment = .center
        intro.skipButtonY = self.view.bounds.size.height * 0.1
        intro.pageControlY = intro.skipButtonY + topInset
        page1.titlePositionY = intro.pageControlY + topInset
        page1.descPositionY = page1.titlePositionY + topInset
        
        page2.titlePositionY = intro.pageControlY + topInset
        page2.descPositionY = page2.titlePositionY + topInset
        
        page3.titlePositionY = intro.pageControlY + topInset
        page3.descPositionY = page3.titlePositionY + topInset
        
        
        page4.descPositionY = intro.pageControlY - self.view.bounds.size.height * 0.3
        
        intro.delegate = self
        intro.show(in: self.view, animateDuration: 0.3)
    }
    
    func introDidFinish(_ introView: EAIntroView!, wasSkipped: Bool) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let nfMainVC = storyboard.instantiateViewController(withIdentifier: "NFSimpleMenuController")
        let navController = UINavigationController(rootViewController: nfMainVC)
        navController.isNavigationBarHidden = true
        let appDelegate = UIApplication.shared.delegate!
        introView.isOpaque = false
        appDelegate.window!!.rootViewController = navController
    }
    
    func introWillFinish(_ introView: EAIntroView!, wasSkipped: Bool) {
        
    }
}
