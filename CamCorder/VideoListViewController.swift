//
//  VideoListViewController.swift
//  CamCorder
//
//  Created by jay on 3/2/17.
//  Copyright © 2017 jay. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import Firebase

class VideoListViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!

    var database: FIRDatabase!
    var videosRef: FIRDatabaseReference!
    var urls = [String]()

    // MARK - lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        database = FIRDatabase.database()
        videosRef = database.reference(withPath: "videos")
        configureCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        observeVideos()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        videosRef.removeAllObservers()
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
        videosRef.observe(.value, with: videosDidUpdate)
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
        let alert = UIAlertController(title: "Hi", message: "You will need to go to settings to allow permissions", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    private func configureCollectionView() {
        
        let gap = (UIScreen.main.bounds.width - 300) / 3
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.minimumLineSpacing = gap
        layout.minimumInteritemSpacing = gap
        layout.sectionInset = UIEdgeInsetsMake(gap, gap, 0, gap)
    }
}

extension VideoListViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return urls.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoCollectionViewCell", for: indexPath) as! VideoCollectionViewCell
        cell.url = urls[indexPath.item]
        return cell
    }
}

extension VideoListViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let url = urls[indexPath.item]
        showVideo(url: URL(string: url)!)
    }
    
    private func showVideo(url: URL) {
        let controller = AVPlayerViewController()
        controller.player = AVPlayer(url: url)
        controller.title = "View"
        navigationController?.pushViewController(controller, animated: true)
    }
}
