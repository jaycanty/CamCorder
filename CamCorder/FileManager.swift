//
//  FileManager.swift
//  CamCorder
//
//  Created by jay on 3/2/17.
//  Copyright © 2017 jay. All rights reserved.
//

import Foundation
import UIKit

class FileManager: NSObject {
    
    static let shared = FileManager()
    
    lazy var uploadQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.name = "Upload Queue"
        queue.maxConcurrentOperationCount = 1
        queue.addObserver(self, forKeyPath: "operationCount", options: .new, context: nil)
        return queue
    }()
    
    func startUpload(url: URL) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let operation = VideoUploader(url: url)
        operation.completionBlock = {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
        uploadQueue.addOperation(operation)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        print("Queue changed: \(uploadQueue.operationCount)")
    }
}
