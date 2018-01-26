//
//  FaceDetectionService.swift
//  Detector
//
//  Created by Don Holly on 1/25/18.
//  Copyright © 2018 Don Holly. All rights reserved.
//

import Foundation
import CoreImage
import Vision
import Photos

class FaceDetectionService {
    
    enum Engine: UInt {
        case appleCI
        case google
        case appleVision
        
        var name: String {
            switch self {
            case .appleCI: return "appleCI"
            case .appleVision: return "appleVision"
            case .google: return "google"
            }
        }
    }
    
    static let faceDetectSerialQueueAppleCI = DispatchQueue(label: "com.ever.face-detect-appleCI", attributes: [])
    static let faceDetectSerialQueueGoogle = DispatchQueue(label: "com.ever.face-detect-google", attributes: [])
    
    fileprivate static let appleDetectorContext = CIContext()
    fileprivate static let appleFaceDetector: CIDetector? = {
        let options: [String: AnyObject] = [
            CIDetectorAccuracy: CIDetectorAccuracyHigh as AnyObject
        ]
        let detector = CIDetector.init(ofType: CIDetectorTypeFace, context: FaceDetectionService.appleDetectorContext, options: options)
        return detector
    }()
    
    fileprivate static let googleFaceDetector: GMVDetector? = {
        let options: [String: AnyObject] = [
            GMVDetectorFaceLandmarkType: GMVDetectorFaceLandmark.all.rawValue as AnyObject,
            GMVDetectorFaceClassificationType: GMVDetectorFaceClassification.all.rawValue as AnyObject,
            GMVDetectorFaceTrackingEnabled: false as AnyObject,
            GMVDetectorFaceMode: GMVDetectorFaceModeOption.accurateMode.rawValue as AnyObject
        ]
        let detector = GMVDetector.init(ofType: GMVDetectorTypeFace, options: options)
        return detector
    }()
    
    class func detectFacesUsingAppleEngine(in image: UIImage, identifier: String) -> FaceDetectionResult {
        
        var result: FaceDetectionResult!
        
        faceDetectSerialQueueAppleCI.sync {
            assert(!Thread.isMainThread, "detectFacesUsingAppleEngine() must not be on the main thread")
            let startTime = Date()
            
            guard let detector = appleFaceDetector else {
                let error = NSError(domain: "FaceDetectionService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Unable to instantiate Apple CIDetector"])
                assertionFailure(error.localizedDescription)
                return
            }
            
            guard let cgImage = image.cgImage else {
                let error = NSError(domain: "FaceDetectionService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Unable to get CGImage from UIImage"])
                assertionFailure(error.localizedDescription)
                result = FaceDetectionResult(faces: nil, identifier: identifier, error: error, timeTaken: 0)
                return
            }
            
            let ciImage = CIImage(cgImage: cgImage)
            
            var options = [String: AnyObject]()
            if let value = ciImage.properties[kCGImagePropertyOrientation as String] {
                options[CIDetectorImageOrientation] = value as AnyObject?
            } else {
                options[CIDetectorImageOrientation] = 1 as AnyObject?
            }
            
            guard let faceFeatures = detector.features(in: ciImage, options: options) as? [CIFaceFeature] else {
                let error = NSError(domain: "FaceDetectionService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Error while processing faces via Apple Engine"])
                assertionFailure(error.localizedDescription)
                result = FaceDetectionResult(faces: nil, identifier: identifier, error: error, timeTaken: 0)
                return
            }
            
            var faces = [Face]()
            faceFeatures.forEach { faceFeature in
                
                let relativeBounds = CGRect(
                    x: faceFeature.bounds.origin.x / image.size.width,
                    y: (image.size.height - faceFeature.bounds.origin.y - faceFeature.bounds.size.height) / image.size.height, // Converting CIImage to UIKit coordinate spaces
                    width: faceFeature.bounds.size.width / image.size.width,
                    height: faceFeature.bounds.size.height / image.size.height)
                
                let face = Face(boundingBox: relativeBounds, localAssetIdentifier: identifier)
                faces.append(face)
            }
            
            let timeTaken = Date().timeIntervalSince(startTime)
            
            result = FaceDetectionResult(faces: faces, identifier: identifier, error: nil, timeTaken: timeTaken)
        }
        
        return result
    }
    
    class func detectFacesUsingGoogleEngine(in image: UIImage, identifier: String) -> FaceDetectionResult {
        
        var result: FaceDetectionResult!
        
        faceDetectSerialQueueGoogle.sync {
            assert(!Thread.isMainThread, "detectFacesUsingGoogleEngine() must not be on the main thread")
            let startTime = Date()
            
            guard let detector = googleFaceDetector else {
                let error = NSError(domain: "FaceDetectionService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Unable to instantiate Google GMVDetector"])
                assertionFailure(error.localizedDescription)
                result = FaceDetectionResult(faces: nil, identifier: identifier, error: error, timeTaken: 0)
                return
            }
            
            guard let faceFeatures = detector.features(in: image, options: nil) as? [GMVFaceFeature] else {
                let error = NSError(domain: "FaceDetectionService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Error while processing faces via Google Engine"])
                assertionFailure(error.localizedDescription)
                result = FaceDetectionResult(faces: nil, identifier: identifier, error: error, timeTaken: 0)
                return
            }
            
            var faces = [Face]()
            faceFeatures.forEach { faceFeature in
                
                let relativeBounds = CGRect(
                    x: faceFeature.bounds.origin.x / image.size.width,
                    y: faceFeature.bounds.origin.y / image.size.height,
                    width: faceFeature.bounds.size.width / image.size.width,
                    height: faceFeature.bounds.size.height / image.size.height)
                
                let face = Face(boundingBox: relativeBounds, localAssetIdentifier: identifier)
                faces.append(face)
            }
            
            let timeTaken = Date().timeIntervalSince(startTime)
            
            result = FaceDetectionResult(faces: faces, identifier: identifier, error: nil, timeTaken: timeTaken)
            
        }
        
        return result
    }
    
    class func detectFacesUsingAppleVisionEngine(in image: UIImage, identifier: String, completion: @escaping (_ result: FaceDetectionResult) -> Void) {
        
        assert(!Thread.isMainThread, "detectFacesUsingAppleVisionEngine() must not be on the main thread")
        let startTime = Date()
        
        guard let cgImage = image.cgImage else {
            let error = NSError(domain: "FaceDetectionService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Couldn't get CGImage from UIImage"])
            assertionFailure(error.localizedDescription)
            let result = FaceDetectionResult(faces: nil, identifier: identifier, error: error, timeTaken: 0)
            completion(result)
            return
        }
        
        let request = VNDetectFaceRectanglesRequest(completionHandler: { request, error in
            let timeTaken = Date().timeIntervalSince(startTime)
            
            guard error == nil else {
                let result = FaceDetectionResult(faces: nil, identifier: identifier, error: error, timeTaken: timeTaken)
                completion(result)
                return
            }
            
            var faces = [Face]()
            
            if let results = request.results as? [VNDetectedObjectObservation] {
                for result in results {
                    let boundingBox = result.boundingBox
                    let face = Face(boundingBox: boundingBox, localAssetIdentifier: identifier)
                    faces.append(face)
                }
            }
            
            let result = FaceDetectionResult(faces: faces, identifier: identifier, error: nil, timeTaken: timeTaken)
            completion(result)
        })
        
        do {
            try VNImageRequestHandler(cgImage: cgImage, options: [:]).perform([request])
        } catch {
            assertionFailure(error.localizedDescription)
            let result = FaceDetectionResult(faces: nil, identifier: identifier, error: error, timeTaken: 0)
            completion(result)
        }
    }
    
    private var internalQueue = DispatchQueue(label: "com.detector.face-services-internal")
    
    private var detectionOperationQueue: OperationQueue = {
        let q = OperationQueue()
        q.name = "com.detector.face-detection-queue"
        q.maxConcurrentOperationCount = 3
        return q
    }()
    
    static var shared: FaceDetectionService = {
        let service = FaceDetectionService()
        return service
    }()
    
    func detectFacesForAllPhotos(usingEngine engine: Engine, targetSize: CGSize, networkAccessAllowed: Bool, progressClosure: @escaping (_ result: FaceDetectionResult?) -> Void) {
        
        PHPhotoLibrary.requestAuthorization { [unowned self] status in
            guard status == .authorized else { return }
            
            self.internalQueue.async { [weak self] in
                self?.detectionOperationQueue.cancelAllOperations()
                
                let options = PHFetchOptions()
                options.includeAllBurstAssets = true
                PHAsset.fetchAssets(with: options).enumerateObjects { [weak self] asset, index, stop in
                    let operation = FaceDetectionOperation(
                        asset: asset,
                        engine: engine,
                        targetSize: targetSize,
                        networkAccessAllowed: networkAccessAllowed,
                        completion: { result in
                            DispatchQueue.main.async {
                                progressClosure(result)
                            }
                    })
                    
                    self?.detectionOperationQueue.addOperation(operation)
                }
            }
        }
    }
    
    func cancelAllJobs() {
        internalQueue.async { [weak self] in
            self?.detectionOperationQueue.cancelAllOperations()
        }
    }
}

extension CGImagePropertyOrientation {
    init(_ uiOrientation: UIImageOrientation) {
        switch uiOrientation {
        case .up: self = .up
        case .upMirrored: self = .upMirrored
        case .down: self = .down
        case .downMirrored: self = .downMirrored
        case .left: self = .left
        case .leftMirrored: self = .leftMirrored
        case .right: self = .right
        case .rightMirrored: self = .rightMirrored
        }
    }
}
