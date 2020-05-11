//
//  Old.swift
//  ARMuseum
//
//  Created by Dron on 10.05.2020.
//  Copyright © 2020 dron. All rights reserved.
//

import UIKit
import ARKit

//TODO: lateruse if need it
extension MainARController {
    func handleFoundObject(_ node: SCNNode, _ anchor: ARObjectAnchor) {
        if let name = anchor.referenceObject.name {
            print("You found a \(name) object")
            let plane = SCNPlane(width: 90, height: 180)
            let planeNode = SCNNode(geometry: plane)
            planeNode.eulerAngles.x = -.pi / 2
            let translation = SCNMatrix4MakeTranslation(0, 0, 0.0001)
            let rotation = SCNMatrix4MakeRotation(-Float.pi / 2, 1, 0, 0)
            let transform = SCNMatrix4Mult(translation, rotation)
            planeNode.transform = transform
            
            self.arInfoContainer = ARInfoContainer(anchor: anchor, plane: plane)
            
            let titleNode = self.createTitleNode(info: name)
            node.addChildNode(titleNode)
        }
        
    }
    
    private func createTitleNode(info: String) -> SCNNode {
        let title = SCNText(string: info, extrusionDepth: 1.0)
        let titleNode = SCNNode(geometry: title)
        titleNode.scale = SCNVector3(0.005, 0.005, 0.005)
        titleNode.position = SCNVector3(-0.5, 0.1, 0.0)
        
        self.createHostingController(for: titleNode, referenceImageName: info)
        return titleNode
    }
    
}

//func createCardOverlayNode(for anchor: ARImageAnchor) -> SCNNode {
//    let box = SCNBox(
//        width: anchor.referenceImage.physicalSize.width, height: 0.0001,
//        length: anchor.referenceImage.physicalSize.height, chamferRadius: 0)
//    if let material = box.firstMaterial {
//        material.diffuse.contents = UIColor.red
//        material.transparency = 0.3
//    }
//    return SCNNode(geometry: box)
//}
//
//func removeARPlaneNode(node: SCNNode) {
//    DispatchQueue.main.async {
//      self.arInfoContainer = nil
//      for childNode in node.childNodes {
//          childNode.removeFromParentNode()
//      }
//    }
//
//}
//
//func createInfoPanelNode(for anchor: ARImageAnchor) -> SCNNode {
//    let controllerWidth = anchor.referenceImage.physicalSize.height/8*9
//    let plane = SCNPlane(width: controllerWidth, height: )
//    let material = SCNMaterial()
////
//    material.locksAmbientWithDiffuse = true
//    material.isDoubleSided = false
//    material.transparency = 1
//
//    let node = SCNNode(geometry: plane)
//    let width = anchor.referenceImage.physicalSize.width/2 + controllerWidth/2
//    let translation = SCNMatrix4MakeTranslation(Float(width), 0, 0.0001)
//    let rotation = SCNMatrix4MakeRotation(-Float.pi / 2, 1, 0, 0)
//    let transform = SCNMatrix4Mult(translation, rotation)
//    node.transform = transform
//
//    self.arInfoContainer = ARInfoContainer(anchor: anchor, plane: plane)
//    self.arInfoContainer?.node = node
//
//    return node
//}
//
//func removeBillboard() {
//    DispatchQueue.main.async {
//        if let anchor = self.arInfoContainer?.anchor {
//            if let viewController = self.arInfoContainer?.viewController {
//                viewController.willMove(toParent: nil)
//                viewController.view.removeFromSuperview()
//                viewController.removeFromParent()
//            }
//            self.sceneView.session.remove(anchor: anchor)
//            self.arInfoContainer?.node?.removeFromParentNode()
//            self.arInfoContainer = nil
//        }
//    }
//
//}


//MARK: - SCNDelegate

//    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
//        guard anchor is ARPlaneAnchor else { return }
//        DispatchQueue.main.async {
//            self.removeBillboard()
//        }
//    }
//
//    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
//        if let imageAnchor = anchor as? ARImageAnchor {
//            if !imageAnchor.isTracked {
//                self.removeBillboard()
//            } else {
//                DispatchQueue.main.async {
//                    if let vc = self.storyboard?.instantiateViewController(withIdentifier: "InfoController") as? InfoController {
//                        self.arInfoContainer?.viewController = vc
//
//                        material.diffuse.contents = vc.view
//                    }
//                }
//
//                plane.materials = [material]
//            }
//        }
//    }
//
//    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
//        if let anchor = anchor as? ARObjectAnchor {
//
//            return SCNNode()
//        } else if let anchor = anchor as? ARImageAnchor {
//            let overlayNode = self.createCardOverlayNode(for: anchor)
//            let info = ExhibitsManager.shared.findExhibitInfo(imageName: anchor.referenceImage.name ?? "")
//
//            let infoPanelNode = self.createInfoPanelNode(for: anchor)
//            self.arInfoContainer?.node = infoPanelNode
//            DispatchQueue.main.async {
//                if let infoVC = self.arInfoContainer?.viewController as? InfoController {
//                    infoVC.info = info
//                }
//            }
//            overlayNode.addChildNode(infoPanelNode)
//            return overlayNode
//        }
//        return nil
//    }
