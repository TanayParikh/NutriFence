//
//  ImageSelectionViewController.swift
//  NutriFence (iOS)
//
//  Created by Matthew Watt on 11/5/16.
//  Copyright © 2016 NutriFence. All rights reserved.
//

import UIKit
import SwiftyJSON

@IBDesignable
class ImageSelectionViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate {

    @IBOutlet weak var takePictureButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var chooseFromLibraryButton: UIButton!
    @IBOutlet var swipeGestureRecognizer: UISwipeGestureRecognizer!
    
    var imagePicker = UIImagePickerController()
    private var backgroundGradient: CAGradientLayer!
    @IBInspectable var gradientTopColor: UIColor!
    @IBInspectable var gradientBottomColor: UIColor!
    static let rgbGrayFontColor = 234
    
    struct ClassificationResult {
        var isSafe: Bool!
        var ingredients: [String]!
    }
    
    let session = URLSession(configuration: URLSessionConfiguration.default)
    
    var googleAPIKey = "AIzaSyDbLtbxBhXGUmQpRyeKQPryCSZZjeKoKmc"
    var googleURL: URL {
        return URL(string: "https://vision.googleapis.com/v1/images:annotate?key=\(googleAPIKey)")!
    }
    
    var classificationURL: URL {
        return URL(string: "http://159.203.50.87:3000/ClassificationAPI")!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createGradientLayer(top: gradientTopColor, bottom: gradientBottomColor)
        customizeButtons()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        swipeGestureRecognizer.direction = .right
        swipeGestureRecognizer.numberOfTouchesRequired = 1
        swipeGestureRecognizer.delegate = self
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print(#function)
        // Dispose of any resources that can be recreated.
    }
    
    // Actions
    
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
    
    @IBAction func swipeGesture(_ sender: UISwipeGestureRecognizer) {
        backButton.sendActions(for: .touchUpInside)
    }
    
    // Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowResultSegue" {
            if let resultsVC = segue.destination as? ResultsViewController {
                if let result = sender as? ClassificationResult {
                    resultsVC.ingredients = result.ingredients
                    resultsVC.isSafe = result.isSafe
                }
            }
        }
    }
    
    @IBAction func unwindToImageSelect(_ segue: UIStoryboardSegue) {
        
    }
    
    
    // Custom drawing
    
    func createGradientLayer(top: UIColor, bottom: UIColor) {
        backgroundGradient = CAGradientLayer()
        backgroundGradient.frame = self.view.bounds
        backgroundGradient.colors = [top.cgColor, bottom.cgColor]
        self.view.layer.insertSublayer(backgroundGradient, at: 0)
    }
    
    func customizeButtons() {
        self.takePictureButton.layer.borderWidth = 1.5
        self.takePictureButton.layer.borderColor = ImageSelectionViewController.customGray().cgColor
        self.chooseFromLibraryButton.layer.borderWidth = 1.5
        self.chooseFromLibraryButton.layer.borderColor = ImageSelectionViewController.customGray().cgColor
    }
    
    // Helpers
    
    static func customGray() -> UIColor {
        return UIColor(red: rgbGrayFontColor, green: rgbGrayFontColor, blue: rgbGrayFontColor)
    }
    
    // Gesture Recognizer Delegate
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.location(in: self.view!).x < (self.view.bounds.width / 3) {
            return true
        }
        return false
    }

}

// Image Processing
extension ImageSelectionViewController {
    func analyzeResults(_ dataToParse: Data) {
        
        // Update UI on the main thread
        DispatchQueue.main.async(execute: { [weak self] Void in
            
            
            // Use SwiftyJSON to parse results
            let json = JSON(data: dataToParse)
            let errorObj: JSON = json["error"]
            
            
            // Check for errors
            if (errorObj.dictionaryValue != [:]) {
                // self.labelResults.text = "Error code \(errorObj["code"]): \(errorObj["message"])"
            } else {
                // Handle the response
                print(json)
                self!.createRequest(withJson: json)
            }
        })
    }
    
    func parseResults(_ json: JSON) {
        print(json)
        var badIngreds = [String]()
        var goodIngreds = [String]()
        var items = json["Bad_Ingredients"].arrayValue
        for item in items {
            print(item.stringValue)
            badIngreds += [item.stringValue]
        }
        items = json["Good_Ingredients"].arrayValue
        for item in items {
            print(item.stringValue)
            goodIngreds += [item.stringValue]
        }
        let isSafe = json["isGlutenFree"].boolValue
        let result = ClassificationResult(isSafe: isSafe, ingredients: (isSafe ? goodIngreds :badIngreds))
        print(#function)
        DispatchQueue.main.async { [weak self] Void in
            self!.performSegue(withIdentifier: "ShowResultSegue", sender: result)
        }
    }
    
    // UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            // Base64 encode the image and create the request
            let binaryImageData = base64EncodeImage(pickedImage)
            createRequest(with: binaryImageData)
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func resizeImage(_ imageSize: CGSize, image: UIImage) -> Data {
        UIGraphicsBeginImageContext(imageSize)
        image.draw(in: CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        let resizedImage = UIImagePNGRepresentation(newImage!)
        UIGraphicsEndImageContext()
        return resizedImage!
    }
}


// Networking

extension ImageSelectionViewController {
    func base64EncodeImage(_ image: UIImage) -> String {
        var imagedata = UIImagePNGRepresentation(image)
        
        // Resize the image if it exceeds the 2MB API limit
        if ((imagedata?.count)! > 2097152) {
            let oldSize: CGSize = image.size
            let newSize: CGSize = CGSize(width: 800, height: oldSize.height / oldSize.width * 800)
            imagedata = resizeImage(newSize, image: image)
        }
        
        return imagedata!.base64EncodedString(options: .endLineWithCarriageReturn)
    }
    
    func createRequest(withJson json: JSON) {
        // Create our request URL
        
        var request = URLRequest(url: classificationURL)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        
        // Serialize the JSON
        guard let data = try? json.rawData() else {
            return
        }
        
        request.httpBody = data
        
        // Run the request on a background thread
        DispatchQueue.global().async { [weak self] Void in
            let task: URLSessionDataTask = self!.session.dataTask(with: request) { (data, response, error) in
                guard let data = data, error == nil else {
                    print(error?.localizedDescription ?? "There was a problem")
                    return
                }
                let dataResult = JSON(data: data)
                self!.parseResults(dataResult)
            }
            
            task.resume()
        }
    }
    
    func createRequest(with imageBase64: String) {
        // Create our request URL
        
        var request = URLRequest(url: googleURL)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(Bundle.main.bundleIdentifier ?? "", forHTTPHeaderField: "X-Ios-Bundle-Identifier")
        
        // Build our API request
        let jsonRequest = [
            "requests": [
                "image": [
                    "content": imageBase64
                ],
                "features": [
                    [
                        "type": "TEXT_DETECTION",
                        "maxResults": 10
                    ]
                ]
            ]
        ]
        let jsonObject = JSON(jsonDictionary: jsonRequest)
        
        // Serialize the JSON
        guard let data = try? jsonObject.rawData() else {
            return
        }
        
        request.httpBody = data
        
        // Run the request on a background thread
        let backgroundQueue = DispatchQueue(label: "com.app.queue",
                                            qos: .background,
                                            target: nil)
        backgroundQueue.async(execute: { [weak self] Void in
            self!.runRequestOnBackgroundThread(request)
        })
    }
    
    func runRequestOnBackgroundThread(_ request: URLRequest) {
        // run the request
        
        let task: URLSessionDataTask = session.dataTask(with: request) { (data, response, error) in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "There was a problem")
                return
            }
            
            self.analyzeResults(data)
        }
        
        task.resume()
    }
}
