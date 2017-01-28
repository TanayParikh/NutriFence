//
//  NFClassificationFetcher.swift
//  NutriFence (iOS)
//
//  Created by Matthew Watt on 11/13/16.
//  Copyright © 2016 NutriFence. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class NFClassificationFetcher {
    
    typealias NutrientData = (conditionTest: String, labelImage: UIImage)
    
    // MARK: - Public API
    
    /**
     Sends an image off to the Classification API for analysis and returns an NFResult

     - returns:
     An optional NFResult containing results of image analysis if the request succeeded, nil if not
     - parameters:
        - data: nutrient image data to be analyzed based on the given condition
        - completion: a closure of type (NFResult) -> Void to be executed (on the main queue) when the network call completes
    */
    class func analyze(_ data: NutrientData, completion: @escaping (NFResult) -> Void) {
        let imageBase64 = base64EncodeImage(data.labelImage)
        let parameters: Parameters = [
            "imageContent" : imageBase64,
            "condition"    : data.conditionTest
        ]
        Alamofire.request(classificationURL,
                          method: .post,
                          parameters: parameters,
                          encoding: JSONEncoding.default)
        .validate(statusCode: 200..<300)
        .validate(contentType: ["application/json"])
        .responseJSON { (jsonResponse) in
            switch jsonResponse.result {
            case .success(let value):
                let json = JSON(value)
                let result = NFClassificationFetcher.parseJSONResult(json)
                DispatchQueue.main.async {
                    completion(result)
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    
    //        let imageBase64 = base64EncodeImage(image)
    //        if let request = urlRequest(withImageBase64: imageBase64) {
    //            print(request.httpBody!.description)
    //            let queue = DispatchQueue(label: "com.nutrifence.background")
    //            queue.async {
    //                let task: URLSessionDataTask = session.dataTask(with: request) { (data, response, error) in
    //                    guard let data = data, error == nil else {
    //                        return
    //                    }
    //                    if let resp = response as? HTTPURLResponse {
    //                        switch resp.statusCode {
    //                        case 200:
    //                            DispatchQueue.main.async {
    //                                print(JSON(data: data))
    //                                completion(JSON(data: data))
    //                            }
    //                        default: break
    //
    //                        }
    //                    }
    //                }
    //                task.resume()
    //            }
    //        }
    
    // MARK: - Private implementation
    
    private static let session = URLSession.shared
    private static let classificationURL = URL(string: "https://node.nutrifence.com:4000/ClassificationAPI")!
    
    
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
    
    // FIXME: implement the parsing method but do gooder than last time
    private class func parseJSONResult(_ json: JSON) -> NFResult {
        return NFResult(safetyStatus: .safe, ingredients: [])
    }
    
    //        var result = NFResult(safetyStatus: .unsafe, ingredients: [])
    //        var ingredients = [NFIngredient]()
    //        if let jsonDict = json.dictionary {
    //            debugPrint(jsonDict)
    //            let isSafe = jsonDict["isGlutenFree"]?.bool!
    //            if isSafe == true {
    //                result.safetyStatus = .safe
    //                if let ingreds = jsonDict["Good_Ingredients"]?.array {
    //                    for goodIngred in ingreds {
    //                        ingredients.append(NFIngredient(with: goodIngred.string!))
    //                    }
    //                }
    //            } else {
    //                print("Setting as .unsafe")
    //                result.safetyStatus = .unsafe
    //                if let ingreds = jsonDict["Bad_Ingredients"]?.array {
    //                    for badIngred in ingreds {
    //                        ingredients.append(NFIngredient(with: badIngred.string!))
    //                    }
    //                }
    //            }
    //            result.ingredients = ingredients
    //        }
    //        hideOverlay()
    //        performSegue(withIdentifier: "LoadResultsSegue", sender: result)

}
