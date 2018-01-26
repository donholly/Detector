//
//  FaceDetectionViewController.swift
//  Detector
//
//  Created by Don Holly on 1/25/18.
//  Copyright © 2018 Don Holly. All rights reserved.
//

import UIKit

class FaceDetectionViewController: UIViewController {

    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var flowLayout: UICollectionViewFlowLayout!
    
    @IBOutlet private weak var engineSelector: UISegmentedControl!
    @IBOutlet private weak var photosScannedValueLabel: UILabel!
    @IBOutlet private weak var photosPerSecondValueLabel: UILabel!
    @IBOutlet private weak var facesPerSecondValueLabel: UILabel!
    @IBOutlet private weak var startButton: UIButton!
    
    private var results = [FaceDetectionResult]()
    private var faces = [Face]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 2, bottom: 0, right: 2)
        flowLayout.minimumLineSpacing = 2
        flowLayout.minimumInteritemSpacing = 2
    }

    @IBAction private func didTapStart(_ button: UIButton) {
        
        button.isSelected = !button.isSelected
        
        if !button.isSelected {
            button.setTitle("Start", for: .normal)
            FaceDetectionService.shared.cancelAllJobs()
            results.removeAll()
            faces.removeAll()
            collectionView.reloadData()
            return
        }
        
        guard let engine = FaceDetectionService.Engine(rawValue: UInt(engineSelector.selectedSegmentIndex)) else {
            assertionFailure("Face Detection Engine not set")
            return
        }
        
        button.setTitle("Stop", for: .normal)
        
        let start = Date()
        
        FaceDetectionService.shared.detectFacesForAllPhotos(
            usingEngine: engine,
            targetSize: CGSize(width: 500, height: 500),
            networkAccessAllowed: false) { [weak self] result in
                guard let strongSelf = self else { return }
                
                if let result = result {
                    if let faces = result.faces {
                        self?.collectionView.performBatchUpdates({ [weak self] in
                            guard let strongSelf = self else { return }
                            var paths = [IndexPath]()
                            faces.forEach { face in
                                let path = IndexPath(item: strongSelf.faces.count, section: 0)
                                paths.append(path)
                                strongSelf.faces.append(face)
                            }
                            strongSelf.collectionView.insertItems(at: paths)
                            }, completion: { _ in
                                
                        })
                    }
                    
                    strongSelf.results.append(result)
                    
                    let duration = Date().timeIntervalSince(start)
                    
                    self?.photosScannedValueLabel.text =   String(format: "Photos: %d", strongSelf.results.count)
                    self?.photosPerSecondValueLabel.text = String(format: "Photos / s: %3.2f", Double(strongSelf.results.count) / duration)
                    self?.facesPerSecondValueLabel.text =  String(format: "Faces / s: %3.2f", Double(strongSelf.faces.count) / duration)
                    
                } else {
                    print("No faces :(")
                }
        }
    }
}

extension FaceDetectionViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return faces.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FaceCollectionViewCellIdentifier", for: indexPath) as? FaceCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.face = faces[indexPath.item]
        return cell
    }
}

extension FaceDetectionViewController: UICollectionViewDelegate {
    
}

extension FaceDetectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding = CGFloat(flowLayout.minimumInteritemSpacing)
        let columns = CGFloat(4)
        let width = floor((collectionView.bounds.width - ((columns+1) * padding)) / columns)
        return CGSize(width: width, height: width)
    }
}
