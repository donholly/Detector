//
//  Face.swift
//  Detector
//
//  Created by Don Holly on 1/25/18.
//  Copyright © 2018 Don Holly. All rights reserved.
//

import Foundation
import CoreGraphics

struct Face {
    let boundingBox: CGRect
    let localAssetIdentifier: String
    
    func absoluteBoundingBox(withImageSize imageSize: CGSize) -> CGRect {
        return CGRect(x: boundingBox.origin.x * imageSize.width,
                      y: boundingBox.origin.y * imageSize.height,
                      width: boundingBox.width * imageSize.width,
                      height: boundingBox.height * imageSize.height)
    }
}
