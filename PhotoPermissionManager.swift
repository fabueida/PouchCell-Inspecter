//
//  PhotoPermissionManager.swift
//  PouchCellInspecter
//
//  Created by Firas Abueida on 1/27/26.
//

import Photos
import SwiftUI
import Combine
final class PhotoPermissionManager: ObservableObject {
    @Published var showDeniedAlert = false
    @Published var permissionGranted = false

    func requestPermission() {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)

        switch status {
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { newStatus in
                DispatchQueue.main.async {
                    self.handle(status: newStatus)
                }
            }
        default:
            handle(status: status)
        }
    }

    private func handle(status: PHAuthorizationStatus) {
        switch status {
        case .authorized, .limited:
            permissionGranted = true
        case .denied, .restricted:
            showDeniedAlert = true
        default:
            break
        }
    }
}
