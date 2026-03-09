//
//  PhotoPermissionManager.swift
//  PouchCellInspecter
//
//  Created by Firas Abueida on 1/27/26.
//

import Photos
import Combine
import UIKit

final class PhotoPermissionManager: ObservableObject {
    @Published var permissionGranted = false
    @Published var showPermissionAlert = false

    init() {
        refreshStatus()
    }

    /// Updates `permissionGranted` based on current Settings.
    /// Does NOT automatically show the alert (so no popup on launch).
    func refreshStatus() {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        DispatchQueue.main.async {
            switch status {
            case .authorized, .limited:
                self.permissionGranted = true
            case .notDetermined, .denied, .restricted:
                self.permissionGranted = false
            @unknown default:
                self.permissionGranted = false
            }
        }
    }

    /// Call this when user taps "Import from Library".
    /// If access is denied/restricted (or user denies the prompt), it sets `showPermissionAlert = true`.
    func requestPermissionAsync() async -> Bool {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)

        // Already denied/restricted → show alert (no prompt)
        if status == .denied || status == .restricted {
            DispatchQueue.main.async {
                self.permissionGranted = false
                self.showPermissionAlert = true
            }
            return false
        }

        // Already authorized/limited
        if status == .authorized || status == .limited {
            DispatchQueue.main.async {
                self.permissionGranted = true
                self.showPermissionAlert = false
            }
            return true
        }

        // Not determined → request
        return await withCheckedContinuation { continuation in
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { newStatus in
                let granted = (newStatus == .authorized || newStatus == .limited)
                DispatchQueue.main.async {
                    self.permissionGranted = granted
                    self.showPermissionAlert = !granted
                    continuation.resume(returning: granted)
                }
            }
        }
    }

    func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
}
