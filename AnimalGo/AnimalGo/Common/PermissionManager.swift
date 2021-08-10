//
//  PermissionManager.swift
//  AnimalGo
//
//  Created by Kiwon on 16/07/2019.
//  Copyright © 2019 AnimalGo. All rights reserved.
//

import AVFoundation
import Photos

class PermissionManager {
    /// 카메라 시스템 권한 팝업
    static func authorizationCamera(success: @escaping VoidClosure, fail: @escaping VoidClosure) {
        if AVCaptureDevice.authorizationStatus(for: .video) == .authorized {
            // Authorized
            success()
        } else {
            getCameraPermission(success: success, fail: fail)
        }
    }
    
    /// 카메라에 접근이 가능 여부
    static func getCameraPermission(success: @escaping VoidClosure, fail: @escaping VoidClosure) {
        AVCaptureDevice.requestAccess(for: .video) { (granted) in
            if granted {
                success()
            } else {
                fail()
            }
        }
    }
    
    /// 앨범 시스템 권한 팝업
    static func authorizationAlbum(success: @escaping VoidClosure, fail: @escaping VoidClosure) {
        if PHPhotoLibrary.authorizationStatus() == .authorized {
            // Authorized
            success()
        } else {
            getAlbumPermission(success: success, fail: fail)
        }
    }
    
    /// 앨범 접근 권한 가능 여부
    static func getAlbumPermission(success: @escaping VoidClosure, fail: @escaping VoidClosure) {
        PHPhotoLibrary.requestAuthorization { (status: PHAuthorizationStatus) in
            if status == .authorized {
                success()
            } else {
                fail()
            }
        }
    }
    
    /// 위치 접근 권한 가능 여부
    static func getLocationPermission(success: @escaping VoidClosure, fail: @escaping VoidClosure) {
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined, .restricted, .denied:
                fail()
            case .authorizedAlways, .authorizedWhenInUse:
                success()
            @unknown default:
                fail()
            }
        } else {
            fail()
        }
        
    }
}
