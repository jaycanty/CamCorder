//
//  VideoUploader.swift
//  CamCorder
//
//  Created by jay on 3/3/17.
//  Copyright © 2017 jay. All rights reserved.
//

import Foundation
import Firebase
import AVFoundation

protocol VideoUploaderDelegate: class {
    
    func update(progress: Float)
    func uploadComplete(success: Bool)
}

class VideoUploader: Operation {
    
    let storage = FIRStorage.storage()
    let database = FIRDatabase.database()
    weak var delegate: FileServiceDelegate?
    var fileURL: URL
    
    init(url: URL) {
        fileURL = url
    }
    
    override func main() {
        prepareAndUpload()
    }
    
    func prepareAndUpload() {
        let id = UUID().uuidString
        uploadFile(forID: id)
        if let image = getDisplayImage() {
            upload(image: image, forID: id)
        }
    }
    
    func uploadFile(forID id: String) {
        let ref = storage.reference(withPath: "videos").child(id)
        let task = ref.putFile(fileURL)
        task.observe(.progress) { snapshot in
            if let complete = snapshot.progress?.completedUnitCount,
                let total = snapshot.progress?.totalUnitCount, total > 0 {
                self.delegate?.update(progress: Float(complete)/Float(total))
            }
        }
        task.observe(.success) { snapshot in
            self.delegate?.uploadComplete(success: true)
            if let videoURL = snapshot.metadata?.downloadURL() {
                self.writeVideo(atURL: videoURL)
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
    
    func writeVideo(atURL videoURL: URL) {
        let ref = database.reference().child("videos")
        let movieRef = ref.childByAutoId()
        movieRef.setValue(videoURL.absoluteString)
    }
    
    func getDisplayImage() -> UIImage? {
        let asset = AVURLAsset(url: fileURL)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        let time = CMTime(seconds: 0, preferredTimescale: 1)
        do {
            let cgImage = try generator.copyCGImage(at: time, actualTime: nil)
            var image: UIImage?
            if let cropped = cgImage.cropping(to: CGRect(x: 0, y: 0, width: 450, height: 600)) {
                image = UIImage(cgImage: cropped)
            }
            return image
        } catch {
            print(error)
            return nil
        }
    }
}
