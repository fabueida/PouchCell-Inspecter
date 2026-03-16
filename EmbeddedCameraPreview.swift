//
//  EmbeddedCameraPreview.swift
//  PouchCellInspector
//
//  Created by Firas Abueida on 2/25/26.
//

import SwiftUI
import Combine
@preconcurrency import AVFoundation
import UIKit

@MainActor
final class EmbeddedCameraModel: NSObject, ObservableObject {

    // MARK: - Nonisolated AVFoundation session (fixes Swift 6 Sendable complaints)
    nonisolated let session = AVCaptureSession()

    private let output = AVCapturePhotoOutput()
    private var device: AVCaptureDevice?

    @Published private(set) var isTorchOn: Bool = false
    @Published private(set) var isSessionRunning: Bool = false

    var onCapture: ((UIImage) -> Void)?

    override init() {
        super.init()
        configureSession()
    }

    private func configureSession() {
        session.beginConfiguration()
        session.sessionPreset = .photo

        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                  for: .video,
                                                  position: .back),
              let input = try? AVCaptureDeviceInput(device: device),
              session.canAddInput(input)
        else {
            session.commitConfiguration()
            return
        }

        self.device = device
        session.addInput(input)

        if session.canAddOutput(output) {
            session.addOutput(output)
        }

        session.commitConfiguration()
    }

    func startSessionIfNeeded() {
        guard !session.isRunning else {
            isSessionRunning = true
            return
        }

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.session.startRunning()
            DispatchQueue.main.async {
                self?.isSessionRunning = true
            }
        }
    }

    func stopSessionIfNeeded() {
        guard session.isRunning else {
            isSessionRunning = false
            return
        }

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.session.stopRunning()
            DispatchQueue.main.async {
                self?.isSessionRunning = false
            }
        }
    }

    func capture() {
        let settings = AVCapturePhotoSettings()
        output.capturePhoto(with: settings, delegate: self)
    }

    /// Keep the name your HomeScreen already calls.
    func toggleFlash() {
        guard let device, device.hasTorch else { return }

        do {
            try device.lockForConfiguration()
            if device.torchMode == .on {
                device.torchMode = .off
                isTorchOn = false
            } else {
                try device.setTorchModeOn(level: AVCaptureDevice.maxAvailableTorchLevel)
                isTorchOn = true
            }
            device.unlockForConfiguration()
        } catch {
            // Keep UI consistent even if torch fails
            isTorchOn = (device.torchMode == .on)
        }
    }
}

extension EmbeddedCameraModel: AVCapturePhotoCaptureDelegate {
    nonisolated func photoOutput(_ output: AVCapturePhotoOutput,
                                didFinishProcessingPhoto photo: AVCapturePhoto,
                                error: Error?) {
        guard error == nil,
              let data = photo.fileDataRepresentation(),
              let image = UIImage(data: data)
        else { return }

        DispatchQueue.main.async { [weak self] in
            self?.onCapture?(image)
        }
    }
}

// MARK: - Preview

struct EmbeddedCameraPreview: UIViewRepresentable {

    @ObservedObject var model: EmbeddedCameraModel

    func makeUIView(context: Context) -> PreviewView {
        let view = PreviewView()
        view.videoPreviewLayer.session = model.session
        view.videoPreviewLayer.videoGravity = .resizeAspectFill
        return view
    }

    func updateUIView(_ uiView: PreviewView, context: Context) {
        uiView.videoPreviewLayer.frame = uiView.bounds
    }
}

final class PreviewView: UIView {
    override class var layerClass: AnyClass { AVCaptureVideoPreviewLayer.self }
    var videoPreviewLayer: AVCaptureVideoPreviewLayer { layer as! AVCaptureVideoPreviewLayer }
}

