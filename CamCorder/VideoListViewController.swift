//
//  VideoListViewController.swift
//  CamCorder
//
//  Created by jay on 3/2/17.
//  Copyright © 2017 jay. All rights reserved.
//

import UIKit
import AVFoundation
import Firebase

class VideoListViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!

    var database: FIRDatabase!
    var urls = [String]()

    // MARK - lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        database = FIRDatabase.database()
        observeVideos()
    }
    
    // MARK - actions
    @IBAction func addVideoButtonHit(_ sender: UIBarButtonItem) {
        checkVideoPermissions() { isVideoAllowed in
            if isVideoAllowed {
                self.checkAudioPermissions() { isAudioAllowed in
                    isAudioAllowed ? self.showVideoCapture() : self.showError()
                }
            } else {
               self.showError()
            }
        }
    }
    
    // MARK: - observe
    
    func observeVideos() {
        
        let ref = database.reference(withPath: "videos")
        ref.observe(.value, with: videosDidUpdate)
    }
    
    func videosDidUpdate(snapshot: FIRDataSnapshot) {
        urls.removeAll()
        for child in snapshot.children {
            if let child = child as? FIRDataSnapshot,
                let value = child.value as? String {
                urls.append(value)
            }
        }
        collectionView.reloadData()
    }
    
    // MARK: - permissions
    private func checkVideoPermissions(complete: @escaping (Bool)->()) {
        let status = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
        if status == .authorized {
            complete(true)
        } else if status == .notDetermined {
            AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo) { success in
                DispatchQueue.main.async {
                    complete(success)
                }
            }
        } else {
            complete(false) // denied or restricted
        }
    }
    
    private func checkAudioPermissions(complete: @escaping (Bool)->()) {
        let status = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeAudio)
        if status == .authorized {
            complete(true)
        } else if status == .notDetermined {
            AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeAudio) { success in
                DispatchQueue.main.async {
                    complete(success)
                }
            }
        } else {
            complete(false) // denied or restricted
        }
    }
    
    private func showVideoCapture() {
        if let videoCaptureViewController = storyboard?.instantiateViewController(withIdentifier: "VideoCaptureViewController") {
            navigationController?.pushViewController(videoCaptureViewController, animated: true)
        }
    }
    
    private func showError() {
        // TODO: show popup
    }
}

extension VideoListViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return urls.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoCollectionViewCell", for: indexPath) as! VideoCollectionViewCell
        cell.url = urls[indexPath.row]
        return cell
    }
}
