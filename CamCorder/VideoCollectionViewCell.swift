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
    
    var url: String! {
        didSet {
            getImageFromVideo()
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imgView.image = nil
    }
    
    private func getImageFromVideo() {
        DispatchQueue.global().async {
            let asset = AVURLAsset(url: URL(string: self.url)!)
            let generator = AVAssetImageGenerator(asset: asset)
            generator.appliesPreferredTrackTransform = true
            let time = CMTime(seconds: 0, preferredTimescale: 1)
            do {
                let imageRef = try generator.copyCGImage(at: time, actualTime: nil)
                DispatchQueue.main.async {
                    let image = UIImage(cgImage: imageRef)
                    self.imgView.image = image
                }
            } catch {
                print(error)
            }
        }
    }
}
