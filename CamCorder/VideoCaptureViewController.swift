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
    
    @IBOutlet weak var progressContainerView: UIView!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var controlButton: UIButton!
    
    let captureSession = AVCaptureSession()
    var movieFileOutput: AVCaptureMovieFileOutput!
    var videoDevice: AVCaptureDevice!
    var fileManager: FileManager?
    let fileService = FileService()
    
    private var state: CaptureState = .stopped

    // MARK - lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "CamCorder"
        fileService.delegate = self
        configureVideoCapture()
        setupProgressView()
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
    
    fileprivate func setupProgressView() {
        progressContainerView.alpha = 0.0
        progressContainerView.layer.cornerRadius = 10
        let shadowPath = UIBezierPath(rect: progressContainerView.bounds)
        progressContainerView.layer.masksToBounds = false
        progressContainerView.layer.shadowColor = UIColor.black.cgColor
        progressContainerView.layer.shadowOffset = CGSize(width: 0.0, height: 5.0)
        progressContainerView.layer.shadowOpacity = 0.5
        progressContainerView.layer.shadowPath = shadowPath.cgPath
    }
    
    fileprivate func showProgress() {
        UIView.animate(withDuration: 0.25, animations: {
            self.progressContainerView.alpha = 1
        })
    }
    
    fileprivate func hideProgress() {
        UIView.animate(withDuration: 0.25, animations: {
            self.progressContainerView.alpha = 0
        })
    }
}

// MARK: - AVCaptureFileOutputRecordingDelegate
extension VideoCaptureViewController: AVCaptureFileOutputRecordingDelegate {
    
    func capture(_ captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAt outputFileURL: URL!, fromConnections connections: [Any]!, error: Error!) {
        print("Did end capture: \(outputFileURL.path)")
        fileService.uploadFile(withURL: outputFileURL)
        showProgress()
    }
}

extension VideoCaptureViewController: FileServiceDelegate {
    
    func update(progress: Float) {
        progressBar.setProgress(progress, animated: true)
    }
    
    func uploadComplete(success: Bool) {
        hideProgress()
    }
}
