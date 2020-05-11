//
//  VirtualInfo.swift
//  ARMuseum
//
//  Created by Dron on 07.05.2020.
//  Copyright © 2020 dron. All rights reserved.
//

import UIKit

class VirtualInfo {
    var text: String?
    var images: [UIImage?] = []
    var audio: String?
    var videoLink: String?
    
    init(text: String?, images: [UIImage?], audio: String?, videoLink: String?) {
        self.text = text
        self.images = images
        self.audio = audio
        self.videoLink = videoLink
    }
}
