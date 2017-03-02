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
    var fileManager: FileManager?
    
    private var state: CaptureState = .stopped

    // MARK - lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

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
        
        switch state {
        case .stopped:
            startRecording()
            state = .recording
        case .recording:
            stopRecording()
            state = .stopped
        }
        navigationController?.setNavigationBarHidden(state == .recording, animated: true)
        sender.isSelected = state == .recording
    }
    
    // MARK: - helpers
    private func startRecording() {
        let fileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("movie.mov")
        movieFileOutput.startRecording( toOutputFileURL: fileURL, recordingDelegate: self)
    }
    
    private func stopRecording() {
        movieFileOutput.stopRecording()
    }
}

// MARK: - AVCaptureFileOutputRecordingDelegate
extension VideoCaptureViewController: AVCaptureFileOutputRecordingDelegate {
    
    func capture(_ captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAt fileURL: URL!, fromConnections connections: [Any]!) {
        fileManager = FileManager()
        fileManager?.startObserving(url: fileURL)
    }
    
    func capture(_ captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAt outputFileURL: URL!, fromConnections connections: [Any]!, error: Error!) {
        print("Did end capture: \(outputFileURL.absoluteString)")
        fileManager?.stopObserving()
        fileManager = nil
    }
}
