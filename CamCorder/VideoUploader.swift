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
    
    private var fileURL: URL
    private var id: String
    private let storage = FIRStorage.storage()
    private let database = FIRDatabase.database()
    weak var delegate: VideoUploaderDelegate?
    
    private var isVideoComplete = false {
        didSet {
           checkAndMarkComplete()
        }
    }
    private var isImageComplete = false {
        didSet {
            checkAndMarkComplete()
        }
    }
    private var _isFinished = false {
        willSet {
            willChangeValue(forKey: "isFinished")
        }
        didSet {
            didChangeValue(forKey: "isFinished")
        }
    }
    private var _isExecuting = false {
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
    
    init(url: URL, id: String) {
        fileURL = url
        self.id = id
    }
    
    override func start() {
        _isExecuting = true
        prepareAndUpload()
    }
    
    private func prepareAndUpload() {
        uploadFile()
        if let image = getDisplayImage() {
            upload(image: image, forID: id)
        }
    }
    
    private func uploadFile() {
        let ref = storage.reference(withPath: "videos").child(id)
        let task = ref.putFile(fileURL)
        task.observe(.progress) { [weak self] snapshot in
            if let complete = snapshot.progress?.completedUnitCount,
                let total = snapshot.progress?.totalUnitCount, total > 0 {
                self?.delegate?.update(progress: Float(complete)/Float(total))
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
    
    private func upload(image: UIImage, forID id: String) {
        guard let data = UIImagePNGRepresentation(image) else {
            return
        }
        let ref = storage.reference(withPath: "images").child(id)
        ref.put(data, metadata: nil) { [weak self] meta, error in
           self?.isImageComplete = true
        }
    }
    
    private func writeVideo(atURL videoURL: URL) {
        let ref = database.reference().child("videos")
        let movieRef = ref.childByAutoId()
        movieRef.setValue(videoURL.absoluteString) { [weak self] error, ref in
            self?.isVideoComplete = true
        }
    }
    
    private func getDisplayImage() -> UIImage? {
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
    
    private func checkAndMarkComplete(shouldRemoveFile: Bool = true) {
        if isImageComplete && isVideoComplete {
            if shouldRemoveFile {
                removeFile()
            }
            _isExecuting = false
            _isFinished = true
        }
    }
    
    private func removeFile() {
        let fm = FileManager.default
        if fm.fileExists(atPath: fileURL.path) {
            do {
              try fm.removeItem(at: fileURL)
            } catch {
                print(error)
            }
        }
    }
}
