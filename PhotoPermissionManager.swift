//
//  PhotoPermissionManager.swift
//  PouchCellInspecter
//
//  Created by Firas Abueida on 1/27/26.
//
import Photos
import Combine

final class PhotoPermissionManager: ObservableObject {
    @Published var permissionGranted = false

    func requestPermissionAsync() async -> Bool {
        await withCheckedContinuation { continuation in
            PHPhotoLibrary.requestAuthorization { status in
                let granted = status == .authorized || status == .limited
                DispatchQueue.main.async {
                    self.permissionGranted = granted
                    continuation.resume(returning: granted)
                }
            }
        }
    }
}

