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
    
    var data: Any! {
        didSet {
            if let url = data as? String {
                fetchImage(url: url)
            } else if let uploader = data as? VideoUploader {
                uploader.delegate = self
                showProgress()
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imgView.image = nil
        progressContainerView.alpha = 0
    }
    
    private func fetchImage(url: String) {
        DispatchQueue.global().async { [weak self] in
            // hack because too lazy to put imageURL up to firebase
            let imageURL = url.replacingOccurrences(of: "videos", with: "images")
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
    
    fileprivate func setupView() {
        layer.cornerRadius = 2
        imgView.layer.cornerRadius = 2
        imgView.clipsToBounds = true
        progressContainerView.alpha = 0.0
        progressContainerView.layer.cornerRadius = 2
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
        progressBar.progress = progress
    }
    
    func uploadComplete(success: Bool) {
        hideProgress()
    }
}
