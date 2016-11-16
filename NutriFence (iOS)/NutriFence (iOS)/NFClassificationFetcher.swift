//
//  NFClassificationFetcher.swift
//  NutriFence (iOS)
//
//  Created by Matthew Watt on 11/13/16.
//  Copyright © 2016 NutriFence. All rights reserved.
//

import UIKit
import SwiftyJSON

class NFClassificationFetcher {
    
    // MARK: - Public API
    
    /**
     Sends an image off to the Classification API for analysis and returns an NFResult

     - returns:
     An optional NFResult containing results of image analysis if the request succeeded, nil if not
     - parameters:
        - image: the image to be analyzed
     - Important:
     Function should be run on a background queue
    */
    class func analyzeImage(_ image: UIImage) -> NFResult? {
        let imageBase64 = base64EncodeImage(image)
        var result: NFResult?
        if let request = urlRequest(withImageBase64: imageBase64) {
            print(request.httpBody!)
            let task: URLSessionDataTask = session.dataTask(with: request) { (data, response, error) in
                guard let data = data, error == nil else {
                    print(error?.localizedDescription ?? "There was a problem")
                    return
                }
                let json = JSON(data)
                print(data)
                print(response!)
                // result = parseJSONResults(JSON(data))
            }
            task.resume()
        }
        return result
    }
    
    // MARK: - Private implementation
    
    private static let session = URLSession(configuration: .default)
    private static let classificationURL = URL(string: "http://159.203.50.87:3000/ClassificationAPI")!
    
    
    private class func urlRequest(withImageBase64 image: String) -> URLRequest? {
        var request = URLRequest(url: classificationURL)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let jsonRequest = [
            "request": [
                "imageContent": image
            ]
        ]
        let jsonObject = JSON(jsonDictionary: jsonRequest)
        
        // Serialize the JSON
        guard let data = try? jsonObject.rawData() else {
            return nil
        }
        
        request.httpBody = data
        
        return request
    }
    
    // IMPLEMENT ME PLZ
    private class func parseJSONResults(_ json: JSON) -> NFResult {
        return NFResult(safetyStatus: .safe, ingredients: [])
    }
    
    private class func base64EncodeImage(_ image: UIImage) -> String {
        var imagedata = UIImagePNGRepresentation(image)
        
        // Resize the image if it exceeds the 2MB API limit
        if ((imagedata?.count)! > 2097152) {
            let oldSize: CGSize = image.size
            let newSize: CGSize = CGSize(width: 800, height: oldSize.height / oldSize.width * 800)
            imagedata = resizeImage(newSize, image: image)
        }
        
        return imagedata!.base64EncodedString(options: .endLineWithCarriageReturn)
    }
    
    private class func resizeImage(_ imageSize: CGSize, image: UIImage) -> Data {
        UIGraphicsBeginImageContext(imageSize)
        image.draw(in: CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        let resizedImage = UIImagePNGRepresentation(newImage!)
        UIGraphicsEndImageContext()
        return resizedImage!
    }
}
