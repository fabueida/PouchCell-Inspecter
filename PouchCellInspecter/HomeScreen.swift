//
//  Homescreen.swift
//  PouchCellInspecter
//
//  Created by Firas Abueida on 11/26/25.
//

import SwiftUI
import Photos
import UIKit

struct HomeScreen: View {

    @StateObject private var cameraManager = CameraPermissionManager()
    @StateObject private var photoPermissionManager = PhotoPermissionManager()

    // MARK: - Menu
    @State private var showMenu = false
    @State private var showSafetyInfo = false

    // MARK: - Camera & Photo
    @State private var showCamera = false
    @State private var showUIKitPicker = false
    @State private var capturedImage: UIImage?

    // MARK: - ML & UI State
    @State private var prediction: String?
    @State private var showLoading = false
    @State private var showResult = false

    private let classifier = ImageClassifier()

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background
                    .ignoresSafeArea()

                VStack(spacing: 36) {

                    Text("PouchCell Inspector")
                        .font(.system(size: 32, weight: .bold))

                    Spacer()

                    // MARK: - Camera Button
                    Button {
                        cameraManager.requestPermission()
                    } label: {
                        Label("Scan", systemImage: "camera.fill")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                            .background(AppTheme.accent)
                            .cornerRadius(18)
                    }
                    .padding(.horizontal, 32)

                    // MARK: - Import Button (NEW FLOW)
                    Button {
                        photoPermissionManager.requestPermission()
                    } label: {
                        Label("Import from Library", systemImage: "photo.on.rectangle")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundColor(AppTheme.accent)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(AppTheme.accent, lineWidth: 2)
                            )
                    }
                    .padding(.horizontal, 64)

                    // MARK: - Safety Info
                    Button {
                        showSafetyInfo = true
                    } label: {
                        Label("Safety Info", systemImage: "info.circle")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.secondary)
                    }

                    Spacer()
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showMenu = true
                    } label: {
                        Image(systemName: "line.3.horizontal")
                            .accessibilityLabel("Menu")
                    }
                }
            }
        }

        // MARK: - MENU
        .sheet(isPresented: $showMenu) {
            MenuView()
        }

        // MARK: - SAFETY INFO
        .sheet(isPresented: $showSafetyInfo) {
            InfoDetailView(
                title: "Safety Information",
                message: "This app provides a visual inspection only and does not replace professional battery testing or safety procedures."
            )
        }

        // MARK: - CAMERA PERMISSION RESULT
        .onChange(of: cameraManager.permissionGranted) { _, granted in
            if granted { showCamera = true }
        }

        // MARK: - PHOTO PERMISSION RESULT
        .onChange(of: photoPermissionManager.permissionGranted) { _, granted in
            if granted { showUIKitPicker = true }
        }

        // MARK: - CAMERA SHEET
        .sheet(isPresented: $showCamera) {
            CameraView { image in
                capturedImage = image
                showCamera = false
                runClassification()
            }
        }

        // MARK: - PHOTO PICKER SHEET
        .sheet(isPresented: $showUIKitPicker) {
            ImagePicker { image in
                capturedImage = image
                runClassification()
            }
        }

        // MARK: - LOADING & RESULT
        .fullScreenCover(isPresented: $showLoading) {
            AnalysisLoadingScreen()
        }
        .fullScreenCover(isPresented: $showResult) {
            DetectionResultScreen(result: prediction ?? "Unknown")
        }

        // MARK: - CAMERA DENIED ALERT
        .alert("Camera Access Required", isPresented: $cameraManager.showPermissionAlert) {
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("We use the camera to inspect the battery for visible bulging.")
        }

        // MARK: - PHOTO DENIED ALERT
        .alert("Photo Access Required", isPresented: $photoPermissionManager.showDeniedAlert) {
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Please allow photo access to import battery images for analysis.")
        }
    }

    // MARK: - Classification
    private func runClassification() {
        guard let image = capturedImage else { return }

        showLoading = true

        DispatchQueue.global(qos: .userInitiated).async {
            let result = classifier.classify(image)

            DispatchQueue.main.async {
                showLoading = false
                prediction = result ?? "Unable to analyze image"
                showResult = true
            }
        }
    }
}
