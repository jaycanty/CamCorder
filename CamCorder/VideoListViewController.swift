//
//  VideoListViewController.swift
//  CamCorder
//
//  Created by jay on 3/2/17.
//  Copyright © 2017 jay. All rights reserved.
//

import UIKit
import AVFoundation

class VideoListViewController: UIViewController {

    // MARK - lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
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
    
    // MARK - helpers
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
