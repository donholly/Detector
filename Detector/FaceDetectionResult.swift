//
//  FaceDetectionResult.swift
//  Detector
//
//  Created by Don Holly on 1/25/18.
//  Copyright © 2018 Don Holly. All rights reserved.
//

import Foundation

struct FaceDetectionResult {
    let faces: [Face]?
    let identifier: String
    let error: Error?
    let timeTaken: TimeInterval
}
