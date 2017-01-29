//
//  UIImage+Base64Encode.swift
//  NutriFence (iOS)
//
//  Created by Matthew Watt on 1/28/17.
//  Copyright © 2017 NutriFence. All rights reserved.
//

import UIKit

/**
 This extension defines a computed property that returns self as a base 64 encoded String
 */

extension UIImage {
    var base64encoded: String {
        var imagedata = UIImagePNGRepresentation(self)
        
        // Resize the image if it exceeds the 2MB API limit
        if ((imagedata?.count)! > 2097152) {
            let oldSize: CGSize = self.size
            let newSize: CGSize = CGSize(width: 800, height: oldSize.height / oldSize.width * 800)
            imagedata = self.resizeImage(newSize)
        }
        
        return imagedata!.base64EncodedString(options: .endLineWithCarriageReturn)
    }
    
    private func resizeImage(_ imageSize: CGSize) -> Data {
        UIGraphicsBeginImageContext(imageSize)
        self.draw(in: CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        let resizedImage = UIImagePNGRepresentation(newImage!)
        UIGraphicsEndImageContext()
        return resizedImage!
    }
}
