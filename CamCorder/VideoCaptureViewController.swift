//
//  VideoCaptureViewController.swift
//  CamCorder
//
//  Created by jay on 3/2/17.
//  Copyright © 2017 jay. All rights reserved.
//

import UIKit
import Foundation
import CoreMedia
import AVFoundation

fileprivate enum CaptureState {
    case stopped
    case recording
}

class VideoCaptureViewController: UIViewController {
    
    @IBOutlet weak var controlButton: UIButton!
    
    let captureSession = AVCaptureSession()
    var videoInputDevice: AVCaptureDeviceInput?
    var movieFileOutput: AVCaptureMovieFileOutput!
    var videoDevice: AVCaptureDevice!
    
    private var state: CaptureState = .stopped

    override func viewDidLoad() {
        super.viewDidLoad()

        // Add video input
        videoDevice = AVCaptureDevice.defaultDevice(
            withDeviceType: AVCaptureDeviceType.builtInWideAngleCamera,
            mediaType: AVMediaTypeVideo,
            position: .front
        )
        do {
            videoInputDevice = try AVCaptureDeviceInput(device: videoDevice)
            if captureSession.canAddInput(videoInputDevice) {
                captureSession.addInput(videoInputDevice)
            }
        } catch {
            print(error)
        }
        
        // Add audio input
        let audioCaptureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeAudio)
        do {
            let audioInput = try AVCaptureDeviceInput(device: audioCaptureDevice)
            if captureSession.canAddInput(audioInput) {
                captureSession.addInput(audioInput)
            }
        } catch {
            print(error)
        }
        
        // Add output
        movieFileOutput = AVCaptureMovieFileOutput()
        if captureSession.canAddOutput(movieFileOutput) {
            captureSession.addOutput(movieFileOutput)
            // Add connection
            let captureConnection = movieFileOutput.connection(withMediaType: AVMediaTypeVideo)!
            if captureSession.canAdd(captureConnection) {
                
                if captureConnection.isVideoStabilizationSupported {
                    captureConnection.preferredVideoStabilizationMode = .auto
                }
            }
        }
        
        // Add capture preview layer
        if let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession) {
            previewLayer.frame = view.bounds
            view.layer.addSublayer(previewLayer)
            previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
            let orientation: AVCaptureVideoOrientation =  AVCaptureVideoOrientation(rawValue: UIDevice.current.orientation.rawValue)!
            previewLayer.connection.videoOrientation = orientation
        }
        
    }
    
    @IBAction func controlButtonHit(_ sender: UIButton) {
        switch state {
        case .stopped:
            sender.isSelected = true
            captureSession.startRunning()
            state = .recording
        case .recording:
            sender.isSelected = false
            captureSession.stopRunning()
            state = .stopped
        }
    }
}

extension VideoCaptureViewController: AVCaptureFileOutputRecordingDelegate {
    
    func capture(_ captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAt fileURL: URL!, fromConnections connections: [Any]!) {
        
        // TODO: maybe set an observer on the file
        print("Did start capture: \(fileURL.absoluteString)")
    }
    
    func capture(_ captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAt outputFileURL: URL!, fromConnections connections: [Any]!, error: Error!) {
        
        print("Did end capture: \(outputFileURL.absoluteString)")
    }
}
