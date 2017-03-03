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
}
