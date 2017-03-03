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
    var movieFileOutput: AVCaptureMovieFileOutput!
    var videoDevice: AVCaptureDevice!
    
    private var state: CaptureState = .stopped

    // MARK - lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "CamCorder"
        configureVideoCapture()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        captureSession.startRunning()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        captureSession.stopRunning()
    }
    
    // MARK: - handlers
    @IBAction func controlButtonHit(_ sender: UIButton) {
        var isRecording = true
        switch state {
        case .stopped:
            startRecording()
            state = .recording
        case .recording:
            isRecording = false
            stopRecording()
            state = .stopped
        }
        navigationController?.setNavigationBarHidden(isRecording, animated: true)
        sender.isSelected = isRecording
    }
    
    // MARK: - helpers
    fileprivate func startRecording() {
        let fileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("movie.mov")
        movieFileOutput.startRecording( toOutputFileURL: fileURL, recordingDelegate: self)
    }
    
    fileprivate func stopRecording() {
        movieFileOutput.stopRecording()
    }
    
    fileprivate func configureVideoCapture() {
        // Add video input
        videoDevice = AVCaptureDevice.defaultDevice(
            withDeviceType: AVCaptureDeviceType.builtInWideAngleCamera,
            mediaType: AVMediaTypeVideo,
            position: .front
        )
        do {
            let videoInputDevice = try AVCaptureDeviceInput(device: videoDevice)
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
            previewLayer.zPosition = -1
            previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
            previewLayer.connection.videoOrientation = .portrait
        }
    }
}

// MARK: - AVCaptureFileOutputRecordingDelegate
extension VideoCaptureViewController: AVCaptureFileOutputRecordingDelegate {
    
    func capture(_ captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAt outputFileURL: URL!, fromConnections connections: [Any]!, error: Error!) {
        print("Did end capture: \(outputFileURL.path)")
        FileManager.shared.startUpload(url: outputFileURL)
    }
}
