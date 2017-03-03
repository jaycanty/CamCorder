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
    
    var fileURL: URL
    let storage = FIRStorage.storage()
    let database = FIRDatabase.database()
    weak var delegate: VideoUploaderDelegate?
    
    var isVideoComplete = false {
        didSet {
           checkAndMarkComplete()
        }
    }
    var isImageComplete = false {
        didSet {
            checkAndMarkComplete()
        }
    }
    var _isFinished = false {
        willSet {
            willChangeValue(forKey: "isFinished")
        }
        didSet {
            didChangeValue(forKey: "isFinished")
        }
    }
    var _isExecuting = false {
        willSet {
            willChangeValue(forKey: "isExecuting")
        }
        didSet {
            didChangeValue(forKey: "isExecuting")
        }
    }
    
    override var isAsynchronous: Bool {
        return true
    }
    
    override var isExecuting: Bool {
        return _isExecuting
    }
    
    override var isFinished: Bool {
        return _isFinished
    }
    
    init(url: URL) {
        fileURL = url
    }
    
    override func start() {
        _isExecuting = true
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
        task.observe(.progress) { [weak self] snapshot in
            if let complete = snapshot.progress?.completedUnitCount,
                let total = snapshot.progress?.totalUnitCount, total > 0 {
                self?.delegate?.update(progress: Float(complete)/Float(total))
                print("progress")
            }
        }
        task.observe(.success) { [weak self] snapshot in
            self?.delegate?.uploadComplete(success: true)
            if let videoURL = snapshot.metadata?.downloadURL() {
                self?.writeVideo(atURL: videoURL)
            }
            print("success")
            task.removeAllObservers()
        }
        task.observe(.failure) { [weak self] snapshot in
            self?.delegate?.uploadComplete(success: false)
            print("failure")
            task.removeAllObservers()
            self?.isVideoComplete = true
        }
    }
    
    func upload(image: UIImage, forID id: String) {
        guard let data = UIImagePNGRepresentation(image) else {
            return
        }
        let ref = storage.reference(withPath: "images").child(id)
        ref.put(data, metadata: nil) { [weak self] meta, error in
           self?.isImageComplete = true
        }
    }
    
    func writeVideo(atURL videoURL: URL) {
        let ref = database.reference().child("videos")
        let movieRef = ref.childByAutoId()
        movieRef.setValue(videoURL.absoluteString) { [weak self] error, ref in
            self?.isVideoComplete = true
        }
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
    
    private func checkAndMarkComplete() {
        if isImageComplete && isVideoComplete {
            _isExecuting = false
            _isFinished = true
        }
    }
}
