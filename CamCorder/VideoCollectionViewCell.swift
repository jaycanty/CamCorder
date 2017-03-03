//
//  VideoCollectionViewCell.swift
//  CamCorder
//
//  Created by jay on 3/2/17.
//  Copyright © 2017 jay. All rights reserved.
//

import UIKit
import AVFoundation

class VideoCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var progressContainerView: UIView!
    @IBOutlet weak var progressBar: UIProgressView!
    
    var url: String! {
        didSet {
            fetchImage()
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imgView.image = nil
    }
    
    private func fetchImage() {
        DispatchQueue.global().async { [weak self] in
            // hack because too lazy to put imageURL up to firebase
            let imageURL = (self?.url.replacingOccurrences(of: "videos", with: "images"))!
            print(imageURL)
            do {
                let data = try Data(contentsOf: URL(string: imageURL)!)
                let image = UIImage(data: data)
                DispatchQueue.main.async {
                    self?.imgView.image = image
                }
            } catch {
                print(error)
            }
        }
    }
    
    fileprivate func setupProgressView() {
        progressContainerView.alpha = 0.0
        progressContainerView.layer.cornerRadius = 10
        let shadowPath = UIBezierPath(rect: progressContainerView.bounds)
        progressContainerView.layer.masksToBounds = false
        progressContainerView.layer.shadowColor = UIColor.black.cgColor
        progressContainerView.layer.shadowOffset = CGSize(width: 0.0, height: 5.0)
        progressContainerView.layer.shadowOpacity = 0.5
        progressContainerView.layer.shadowPath = shadowPath.cgPath
    }
    
    fileprivate func showProgress() {
        UIView.animate(withDuration: 0.25, animations: {
            self.progressContainerView.alpha = 1
        })
    }
    
    fileprivate func hideProgress() {
        UIView.animate(withDuration: 0.25, animations: {
            self.progressContainerView.alpha = 0
        })
    }
}

extension VideoCollectionViewCell: VideoUploaderDelegate {
    
    func update(progress: Float) {
        showProgress()
    }
    
    func uploadComplete(success: Bool) {
        hideProgress()
    }
}
