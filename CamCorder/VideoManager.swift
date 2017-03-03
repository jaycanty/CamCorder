//
//  FileManager.swift
//  CamCorder
//
//  Created by jay on 3/2/17.
//  Copyright © 2017 jay. All rights reserved.
//

import Foundation
import UIKit

class VideoManager: NSObject {
    
    static let shared = VideoManager()
    
    lazy var uploadQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.name = "Upload Queue"
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    func startUpload(url: URL, id: String) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let operation = VideoUploader(url: url, id: id)
        operation.completionBlock = {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
        uploadQueue.addOperation(operation)
    }
}
