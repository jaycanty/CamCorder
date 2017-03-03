//
//  FileService.swift
//  CamCorder
//
//  Created by jay on 3/2/17.
//  Copyright © 2017 jay. All rights reserved.
//

import Foundation
import Firebase

protocol FileServiceDelegate: class {
    
    func update(progress: Float)
    func uploadComplete(success: Bool)
}

class FileService {
    
    let storage = FIRStorage.storage()
    weak var delegate: FileServiceDelegate?
    
    func uploadFile(withURL url: URL) {

        let ref = storage.reference().child("movie.mov")
        let task = ref.putFile(url)
        
        task.observe(.progress) { snapshot in
            if let complete = snapshot.progress?.completedUnitCount,
            let total = snapshot.progress?.totalUnitCount, total > 0 {
                self.delegate?.update(progress: Float(complete)/Float(total))
            }
        }
        
        task.observe(.success) { snapshot in
            self.delegate?.uploadComplete(success: true)
        }
        
        task.observe(.failure) { snapshot in
            self.delegate?.uploadComplete(success: false)
        }
    }
}
