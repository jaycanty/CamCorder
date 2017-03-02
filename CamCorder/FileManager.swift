//
//  FileManager.swift
//  CamCorder
//
//  Created by jay on 3/2/17.
//  Copyright © 2017 jay. All rights reserved.
//

import Foundation


class FileManager {
    
    let queue = DispatchQueue.global(qos: .default)
    var fileDescriptor: CInt = -1
    var source: DispatchSourceFileSystemObject!
    
    func startObserving(url: URL) {
        fileDescriptor = open(url.path, O_EVTONLY)
        source = DispatchSource.makeFileSystemObjectSource(fileDescriptor: fileDescriptor, eventMask: .write, queue: queue)
        source.setEventHandler() {
            print("Woho: file was written")
        }
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
    
    deinit {
        print("deinit")
    }
}
