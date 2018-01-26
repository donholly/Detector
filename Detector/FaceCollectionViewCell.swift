//
//  FaceCollectionViewCell.swift
//  Detector
//
//  Created by Don Holly on 1/25/18.
//  Copyright © 2018 Don Holly. All rights reserved.
//

import UIKit
import Photos

class FaceCollectionViewCell: UICollectionViewCell {
    @IBOutlet private weak var imageView: UIImageView!
    
    var face: Face? {
        didSet {
            setupFace()
        }
    }
    
    override func prepareForReuse() {
        imageView.image = nil
    }
    
    private func setupFace() {
        guard let face = face,
            let asset = PHAsset.fetchAssets(withLocalIdentifiers: [face.localAssetIdentifier], options: nil).firstObject else {
                imageView.image = nil
                return
        }
        
        let options = PHImageRequestOptions()
        options.isNetworkAccessAllowed = true
        options.deliveryMode = .highQualityFormat
        options.resizeMode = .fast
        
        let targetSize = imageView.bounds.enlargedBy(2.0, percentY: 2.0).size
        
        PHImageManager.default().requestImage(
            for: asset,
            targetSize: targetSize,
            contentMode: .aspectFill,
            options: options, resultHandler: { [weak self] image, info in
                if let image = image {
                    let croppedRect = face.absoluteBoundingBox(withImageSize: image.size)
                    self?.imageView.image = image.cropped(toRect: croppedRect)
                }
        })
    }
}
