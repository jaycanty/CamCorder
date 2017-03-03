//
//  FileService.swift
//  CamCorder
//
//  Created by jay on 3/2/17.
//  Copyright © 2017 jay. All rights reserved.
//

import Foundation
import Firebase

class FileService {
    
    let storage = FIRStorage.storage()
    
    func uploadFile(withURL url: URL) {

        let ref = storage.reference().child("movie.mov")
        let task = ref.putFile(url)
        
        task.observe(.progress) { snapshot in
         
            print("made progress: \(snapshot.progress?.completedUnitCount) \(snapshot.progress?.totalUnitCount)")
        }
        
        task.observe(.success) { snapshot in
            
            print("success: \(snapshot.metadata?.size)")
        }
        
        task.observe(.failure) { snapshot in
            
            print("failure: \(snapshot.metadata?.size)")
        }
    }
}
