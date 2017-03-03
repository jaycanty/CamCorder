//
//  FileManager.swift
//  CamCorder
//
//  Created by jay on 3/2/17.
//  Copyright © 2017 jay. All rights reserved.
//

import Foundation


class FileManager {
    
    static let shared = FileManager()
    
    lazy var uploadQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.name = "Upload Queue"
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    func startUpload(url: URL) {
        let operation = VideoUploader(url: url)
        uploadQueue.addOperation(operation)
    }
}
