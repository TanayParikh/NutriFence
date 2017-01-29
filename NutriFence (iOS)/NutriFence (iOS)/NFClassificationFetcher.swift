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
    
    private static let classificationURL = URL(string: "https://node.nutrifence.com:4000/ClassificationAPI")!
    
    // MARK: - Public API
    
    
    /**
     Type NutrientData is a tuple that contains a condition String and an image to be analyzed
     */
    typealias NutrientData = (conditionTest: NFDiet, labelImage: UIImage)
    
    public enum NFDiet: String {
        case celiac = "celiac"
        case lactoseIntolerant = "lactoseIntolerant"
        case vegan = "vegan"
        case vegetarian = "vegetarian"
    }
    
    /**
     Sends an image off to the Classification API for analysis and returns an NFResult

     - returns:
     An optional NFResult containing results of image analysis if the request succeeded, nil if not
     - parameters:
        - data: nutrient image data to be analyzed based on the given condition
        - completion: a closure of type (NFResult) -> Void to be executed (on the main queue) when the network call completes
    */
    class func analyze(_ data: NutrientData, completion: @escaping (NFResult) -> Void) {
        let imageBase64 = data.labelImage.base64encoded
        let parameters: Parameters = [
            "imageContent" : imageBase64,
            "condition"    : data.conditionTest.rawValue
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
                let result = parseJSONResult(json)
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
    
    private static let kGoodIngredientJSONKey = "Good_Ingredients"
    private static let kBadIngredientJSONKey = "Bad_Ingredients"
    private static let kPassesTestJSONKey = "Passes_Test"
    
    
    private class func parseJSONResult(_ json: JSON) -> NFResult {
        let goodIngredients = json[kGoodIngredientJSONKey].arrayValue.map({ NFIngredient(with: $0.stringValue) })
        let badIngredients = json[kBadIngredientJSONKey].arrayValue.map({ NFIngredient(with: $0.stringValue) })
        let didPassTest = json[kPassesTestJSONKey].boolValue
        return NFResult(safetyStatus: didPassTest ? .safe : .unsafe,
                        ingredients: didPassTest ? goodIngredients : badIngredients)
    }
    
    /* Response format
    
    {"Bad_Ingredients":[],
     "Good_Ingredients":
     ["wheat flour","niacin","reduced corn syrup fructose","glycerin","processed with alkali","polydextrose","modified corn starch","salt","palm calcium sulfate","distilled monoglycerides","hydrogenated kernel oil","sodium stearoyl lactylate","Gelman","color added","soy lecithin","datem","natural and artificial flavor vanilla extract carnauba wax","xanthan gum","vitamin a palmitate","yellow i5 lake","red f40 lake","caramel color","niacinamide","blue /2 lake","reduced Ron","yellow lake","pyridoxine hydrochloride vitamin b6","","vitamin b2","vitamin b1","","citric acid folic acid","red f40","yellow f5","yellow f6","blue f2","bluef1"],
     "May_Contain":[],
     "Passes_Test":true}
 
    */
    
    
    
    
    
    
    
    
    
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
