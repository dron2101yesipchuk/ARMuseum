//
//  ARInfoContainer.swift
//  ARMuseum
//
//  Created by Dron on 07.05.2020.
//  Copyright © 2020 dron. All rights reserved.
//

import ARKit

struct ARInfoContainer {
    var info: VirtualInfo?
    var anchor: ARAnchor
    var node: SCNNode?
    var plane: SCNPlane
    var isFullScreen = false
    var viewController: InfoController?
    
    init(anchor: ARAnchor, plane: SCNPlane) {
    //    self.billboardData = billboardData
        self.plane = plane
        self.anchor = anchor
      }
}
