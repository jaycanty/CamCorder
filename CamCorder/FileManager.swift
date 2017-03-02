//
//  FileManager.swift
//  CamCorder
//
//  Created by jay on 3/2/17.
//  Copyright © 2017 jay. All rights reserved.
//

import Foundation


class FileManager {
    
    var url: URL
    let queue = DispatchQueue.global(qos: .default)
    var fileDescriptor: CInt = -1
    var source: DispatchSourceFileSystemObject!
    
    init(url: URL) {
        self.url = url
    }
    
    deinit {
        print("deinit")
    }
    
    func startObserving() {
        fileDescriptor = open(url.path, O_EVTONLY)
        source = DispatchSource.makeFileSystemObjectSource(fileDescriptor: fileDescriptor, eventMask: .write, queue: queue)
        source.setEventHandler(handler: fileChanged)
        source.setCancelHandler() {
            print("Cancel")
            close(self.fileDescriptor)
        }
        source.resume()
    }
    
    func stopObserving() {
        close(self.fileDescriptor)
        source = nil
    }
    
    func fileChanged() {
        let eventTypes = source.data
        if eventTypes == .write {
//            print("file was written to")
            do {
                let data = try Data(contentsOf: url, options: .alwaysMapped)
                print(data.count)
            } catch {
                print(error)
            }
            
            
        }
    }
}
