//
//  MainARShowingInfoExtension.swift
//  ARMuseum
//
//  Created by Dron on 07.06.2020.
//  Copyright © 2020 dron. All rights reserved.
//

import UIKit
import ARKit

// Showing info
extension MainARController {
    func showImageInfo(imageAnchor: ARImageAnchor, node: SCNNode) {
        let controllerWidth = imageAnchor.referenceImage.physicalSize.height/8*9
        let plane = SCNPlane(width: controllerWidth,
                             height: imageAnchor.referenceImage.physicalSize.height*2)
        
        let planeNode = SCNNode(geometry: plane)
        planeNode.eulerAngles.x = -.pi / 2
        let width = imageAnchor.referenceImage.physicalSize.width/2 + controllerWidth/2
        let translation = SCNMatrix4MakeTranslation(Float(width), 0, 0.0001)
        let rotation = SCNMatrix4MakeRotation(-Float.pi / 2, 1, 0, 0)
        let transform = SCNMatrix4Mult(translation, rotation)
        planeNode.transform = transform
        
        self.arInfoContainer = ARInfoContainer(anchor: imageAnchor, plane: plane)
        self.createHostingController(for: planeNode, referenceImageName:  imageAnchor.referenceImage.name ?? "")
        self.createVideoNode(imageAnchor: imageAnchor, node: node)
        
        node.addChildNode(planeNode)
    }
    
    func showObjectInfo(objectAnchor: ARObjectAnchor, node: SCNNode) {
        self.removeHostingController()
        
        let plane = SCNPlane(width: CGFloat(objectAnchor.referenceObject.extent.x * 0.9), height: CGFloat(objectAnchor.referenceObject.extent.y * 1.8))
        let planeNode = SCNNode(geometry: plane)
        if let rotate = sceneView.session.currentFrame?.camera.transform {
            node.simdTransform = rotate
        }
        
        let translation = SCNMatrix4MakeTranslation(0.1, 0.15, 0)
        let rotation = SCNMatrix4MakeRotation(0, 0, 0, 0)
        let transform = SCNMatrix4Mult(translation, rotation)
        planeNode.transform = transform
        
        self.arInfoContainer = ARInfoContainer(anchor: objectAnchor, plane: plane)
        self.createHostingController(for: planeNode, referenceImageName:  objectAnchor.referenceObject.name ?? "")
        
        node.addChildNode(planeNode)
    }
    
    func createVideoNode(imageAnchor: ARImageAnchor, node: SCNNode) {
        if let videoUrl = ExhibitsManager.shared.findExhibitInfo(exhibitName: imageAnchor.referenceImage.name ?? "")?.videoLink {
            let url = URL(string: videoUrl)!
            
            let player = AVPlayer(url: url)
            let videoNode = SKVideoNode(avPlayer: player)
            videoNode.play()
            videoNode.size = CGSize(width: 1024, height: 1024)
            let videoScene = SKScene(size: CGSize(width: 1024, height: 1024))
            videoScene.scaleMode = .aspectFit
            videoNode.position = CGPoint(x: videoScene.size.width / 2, y: videoScene.size.height / 2)
            videoNode.yScale = -1.0
            videoScene.addChild(videoNode)
            let plane = SCNPlane(width: imageAnchor.referenceImage.physicalSize.width, height: imageAnchor.referenceImage.physicalSize.height)
            plane.firstMaterial?.diffuse.contents = videoScene
            let planeNode = SCNNode(geometry: plane)
            planeNode.eulerAngles.x = -Float.pi / 2
            let height = imageAnchor.referenceImage.physicalSize.height
            let translation = SCNMatrix4MakeTranslation(0, Float(height), 0.0001)
            let rotation = SCNMatrix4MakeRotation(-Float.pi / 2, 1, 0, 0)
            let transform = SCNMatrix4Mult(translation, rotation)
            planeNode.transform = transform
            node.addChildNode(planeNode)
             self.arInfoContainer?.videoNode = planeNode
            
             self.arInfoContainer?.videoPlayer = player
             self.arInfoContainer?.videoPlayer?.pause()
        }
    }
    
    func createHostingController(for node: SCNNode, referenceImageName: String) {
        DispatchQueue.main.async {
            guard let arVC = self.storyboard?.instantiateViewController(withIdentifier: "InfoCollectionController") as? InfoCollectionController,
                let exhibitInfo = ExhibitsManager.shared.findExhibitInfo(exhibitName: referenceImageName) else {
                    return
            }
            
            self.arInfoContainer?.info = exhibitInfo
            NotificationsManager.shared.postAudioFoundNotification(exhibitInfo.audio != nil)
            self.arInfoContainer?.viewController = arVC
            self.arInfoContainer?.node = node
            self.arInfoContainer?.videoPlayerDelegate = self
            
            arVC.arInfoContainer = self.arInfoContainer
            
//            if self.isBlindModeOn {
//                NotificationsManager.shared.postAudioFoundNotification(exhibitInfo.audio != nil)
//            }
            
            arVC.willMove(toParent: self)
            self.addChild(arVC)
            self.view.addSubview(arVC.view)
            
            let material = SCNMaterial()
            material.locksAmbientWithDiffuse = true
            material.isDoubleSided = false
            material.transparency = 1
            
            arVC.view.isOpaque = false
            material.diffuse.contents = arVC.view
            node.geometry?.materials = [material]
        }
    }
    
    func removeHostingController() {
        if let anchor = arInfoContainer?.anchor {
            if let viewController = arInfoContainer?.viewController {
                DispatchQueue.main.async {
                    viewController.willMove(toParent: nil)
                    viewController.view.removeFromSuperview()
                    viewController.removeFromParent()
                }
                
            }
            self.sceneView.session.remove(anchor: anchor)
            self.arInfoContainer?.node?.removeFromParentNode()
            self.arInfoContainer = nil
        }
    }
}
