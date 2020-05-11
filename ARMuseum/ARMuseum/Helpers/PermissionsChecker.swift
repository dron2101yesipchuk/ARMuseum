//
//  Permissions checker.swift
//  DirectAutoApp
//
//  Created by Dron on 09.03.2020.
//  Copyright © 2020 vallsoft. All rights reserved.
//

import AVFoundation
import Photos

class PermissionsChecker {
    class func checkCameraPermissions(_ completion: @escaping (Bool)->()) {
        if AVCaptureDevice.authorizationStatus(for: AVMediaType.video) ==  AVAuthorizationStatus.authorized {
            completion(true)
        } else {
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { (granted: Bool) -> Void in
               completion(granted)
           })
        }
    }
}
