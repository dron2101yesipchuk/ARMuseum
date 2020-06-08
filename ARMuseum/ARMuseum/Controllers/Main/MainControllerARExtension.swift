//
//  MainControllerARExtension.swift
//  ARMuseum
//
//  Created by Dron on 07.06.2020.
//  Copyright © 2020 dron. All rights reserved.
//

import UIKit
import ARKit

extension MainARController : ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        feedbackGenerator.notificationOccurred(.success)
        if let objectAnchor = anchor as? ARObjectAnchor {
            self.showObjectInfo(objectAnchor: objectAnchor, node: node)
        } else if let imageAnchor = anchor as? ARImageAnchor {
            self.showImageInfo(imageAnchor: imageAnchor, node: node)
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        if let imageAnchor = anchor as? ARImageAnchor {
            node.isHidden = !imageAnchor.isTracked
        }
    }
}
