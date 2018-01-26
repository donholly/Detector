//
//  FaceDetectionOperation.swift
//  Detector
//
//  Created by Don Holly on 1/25/18.
//  Copyright © 2018 Don Holly. All rights reserved.
//

import Foundation
import Photos

class FaceDetectionOperation: AsynchronousOperation {
    
    private var asset: PHAsset
    private var engine: FaceDetectionService.Engine
    private var targetSize: CGSize
    private var networkAccessAllowed: Bool
    private var completion: (_ result: FaceDetectionResult?) -> Void
    
    init(asset: PHAsset, engine: FaceDetectionService.Engine, targetSize: CGSize, networkAccessAllowed: Bool, completion: @escaping (_ result: FaceDetectionResult?) -> Void) {
        self.asset = asset
        self.engine = engine
        self.targetSize = targetSize
        self.networkAccessAllowed = networkAccessAllowed
        self.completion = completion
    }
    
    override func execute() {
        
        let options = PHImageRequestOptions()
        options.isNetworkAccessAllowed = networkAccessAllowed
        options.deliveryMode = .fastFormat
        options.resizeMode = PHImageRequestOptionsResizeMode.exact
        
        PHImageManager.default().requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFit, options: options) { [weak self] image, info in
            DispatchQueue.global(qos: .userInitiated).async {
                guard let strongSelf = self else { return }
                guard strongSelf.isCancelled == false else { return }
                
                guard let image = image else {
                    strongSelf.completion(nil)
                    strongSelf.finish()
                    return
                }
                
                switch strongSelf.engine {
                case .appleCI:
                    let result = FaceDetectionService.detectFacesUsingAppleEngine(in: image, identifier: strongSelf.asset.localIdentifier)
                    strongSelf.completion(result)
                    strongSelf.finish()
                case .google:
                    let result = FaceDetectionService.detectFacesUsingAppleEngine(in: image, identifier: strongSelf.asset.localIdentifier)
                    strongSelf.completion(result)
                    strongSelf.finish()
                case .appleVision:
                    FaceDetectionService.detectFacesUsingAppleVisionEngine(in: image, identifier: strongSelf.asset.localIdentifier, completion: { [weak self] result in
                        guard let strongSelf = self else { return }
                        guard strongSelf.isCancelled == false else { return }
                        strongSelf.completion(result)
                        strongSelf.finish()
                    })
                }
            }
        }
    }
    
    
}
