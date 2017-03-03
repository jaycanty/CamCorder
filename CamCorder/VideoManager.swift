//
//  FileManager.swift
//  CamCorder
//
//  Created by jay on 3/2/17.
//  Copyright © 2017 jay. All rights reserved.
//

import Foundation
import UIKit

class VideoManager {
    
    static let shared = VideoManager()
    
    private lazy var uploadQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.name = "Upload Queue"
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    var operations: [Operation] {
        return uploadQueue.operations
    }
    
    func startUpload(url: URL, id: String) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let operation = VideoUploader(url: url, id: id)
        operation.completionBlock = {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
        uploadQueue.addOperation(operation)
    }
}
