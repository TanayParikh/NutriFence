//
//  NFClassificationFetcher.swift
//  NutriFence (iOS)
//
//  Created by Matthew Watt on 11/13/16.
//  Copyright © 2016 NutriFence. All rights reserved.
//
/**
 This file contains the code required to reach out to Nutrifence's backend for
 analysis of ingredients labels captured within the application, as well as defining
 protocols for handling the results of the analysis
 */

import UIKit
import SwiftyJSON
import Alamofire


public class NFClassificationFetcher {
    
    private static let classificationURLString = "https://node.nutrifence.com:4000/ClassificationAPI"
    
    // MARK: - Public API
    
    /**
     Type NutrientData is a tuple that contains a condition String and an image to be analyzed
     */
    public typealias NutrientData = (conditionTest: Diet, labelImage: UIImage)
    
    /**
     Represents a diet used by the NFClassificationFetcher API
     - Important:
     The rawValue for NFDiet is used to make the network request, while the displayString
     computed propery is used for displaying diets in the UI
     */
    public enum Diet: String {
        case celiac = "celiac"
        case lactoseIntolerant = "lactoseIntolerant"
        case vegan = "vegan"
        case vegetarian = "vegetarian"
        public var displayString: String {
            switch self {
            case .celiac:
                return "Celiac's"
            case .lactoseIntolerant:
                return "Lactose intolerant"
            case .vegan:
                return "Vegan"
            case .vegetarian:
                return "Vegetarian"
            }
        }
        public static var list: [Diet] {
            return [Diet.celiac, .lactoseIntolerant, .vegan, .vegetarian]
        }
    }
    
    /**
     Describes the safety status of a Result
     */
    public enum ProductSafetyStatus {
        case safe
        case unsafe
        
        var description: String {
            switch self {
            case .safe:
                return "Safe"
            case .unsafe:
                return "Unsafe"
            }
        }
    }
    
    /**
     A wrapper around a simple String used to represent an Ingredient in a Result from 
     the NFClassificationFetcher API
     */
    public struct Ingredient {
        var name: String
        
        init(with name: String) {
            self.name = name
        }
    }
    
    /**
     A type to contain the results of an ingredient analysis
     */
    public struct Result: CustomDebugStringConvertible {
        var safetyStatus: ProductSafetyStatus?
        var ingredients: [Ingredient]?
        var error: Error?
        
        public var debugDescription: String {
            if error == nil && safetyStatus != nil && ingredients != nil {
                return "Status: \(self.safetyStatus!.description)\nIngredients:\n\t\(ingredients)"
            } else {
                return "\(error!.localizedDescription)"
            }
        }
    }
    
    /**
     Sends an image off to the Classification API for analysis and returns a Result

     - parameters:
        - data: nutrient image data to be analyzed based on the given condition
        - completion: a closure of type (Result) -> Void to be executed (on the main queue) when the network call completes
    */
    public class func analyze(_ data: NutrientData, completion: @escaping (Result) -> Void) {
        let imageBase64 = data.labelImage.base64encoded
        let parameters: Parameters = [
            "imageContent" : imageBase64,
            "condition"    : data.conditionTest.rawValue
        ]
        Alamofire.request(classificationURLString,
                          method: .post,
                          parameters: parameters,
                          encoding: JSONEncoding.default)
        .validate()
        .responseJSON { (jsonResponse) in
            switch jsonResponse.result {
            case .success(let value):
                let json = JSON(value)
                let result = parseJSONResult(json)
                DispatchQueue.main.async {
                    completion(result)
                }
            case .failure(let error):
                let result = Result(safetyStatus: nil, ingredients: nil, error: error)
                DispatchQueue.main.async {
                    completion(result)
                }
            }
        }
    }
    
    private static let kGoodIngredientJSONKey = "Good_Ingredients"
    private static let kBadIngredientJSONKey = "Bad_Ingredients"
    private static let kPassesTestJSONKey = "Passes_Test"
    
    
    private class func parseJSONResult(_ json: JSON) -> Result {
        let goodIngredients = json[kGoodIngredientJSONKey].arrayValue.map({ Ingredient(with: $0.stringValue) })
        let badIngredients = json[kBadIngredientJSONKey].arrayValue.map({ Ingredient(with: $0.stringValue) })
        let didPassTest = json[kPassesTestJSONKey].boolValue
        return Result(safetyStatus: didPassTest ? .safe : .unsafe,
                        ingredients: didPassTest ? goodIngredients : badIngredients,
                        error: nil)
    }
}
