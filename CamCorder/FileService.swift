//
//  FileService.swift
//  CamCorder
//
//  Created by jay on 3/2/17.
//  Copyright © 2017 jay. All rights reserved.
//

import Foundation
import Firebase
import AVFoundation

protocol FileServiceDelegate: class {
    
    func update(progress: Float)
    func uploadComplete(success: Bool)
}

class FileService {
    
    let storage = FIRStorage.storage()
    let database = FIRDatabase.database()
    weak var delegate: FileServiceDelegate?
    
    func prepareAndUpload(videoAtURL url: URL) {
        let id = UUID().uuidString
        uploadFile(withURL: url, forID: id)
        getDisplayImage(fromURL: url, complete: { [weak self] image in
            if let image = image {
                self?.upload(image: image, forID: id)
            }
        })
    }
    
    func uploadFile(withURL url: URL, forID id: String) {
        let ref = storage.reference(withPath: "videos").child(id)
        let task = ref.putFile(url)
        task.observe(.progress) { snapshot in
            if let complete = snapshot.progress?.completedUnitCount,
            let total = snapshot.progress?.totalUnitCount, total > 0 {
                self.delegate?.update(progress: Float(complete)/Float(total))
            }
        }
        task.observe(.success) { snapshot in
            self.delegate?.uploadComplete(success: true)
            if let url = snapshot.metadata?.downloadURL() {
                DispatchQueue.global().async {
                    self.write(url: url)
                }
            }
            task.removeAllObservers()
        }
        task.observe(.failure) { snapshot in
            self.delegate?.uploadComplete(success: false)
            task.removeAllObservers()
        }
    }
    
    func upload(image: UIImage, forID id: String) {
        guard let data = UIImagePNGRepresentation(image) else {
            return
        }
        let ref = storage.reference(withPath: "images").child(id)
        let _ = ref.put(data)
    }
    
    func write(url: URL) {
        let ref = database.reference().child("videos")
        let movieRef = ref.childByAutoId()
        movieRef.setValue(url.absoluteString)
    }
    
    func getDisplayImage(fromURL url: URL, complete: @escaping (UIImage?) -> ()) {
        
        DispatchQueue.global().async {
            let asset = AVURLAsset(url: url)
            let generator = AVAssetImageGenerator(asset: asset)
            generator.appliesPreferredTrackTransform = true
            let time = CMTime(seconds: 0, preferredTimescale: 1)
            do {
                let cgImage = try generator.copyCGImage(at: time, actualTime: nil)
                var image: UIImage?
                if let cropped = cgImage.cropping(to: CGRect(x: 0, y: 0, width: 450, height: 600)) {
                   image = UIImage(cgImage: cropped)
                }
                complete(image)
            } catch {
                print(error)
                complete(nil)
            }
        }
    }
}
