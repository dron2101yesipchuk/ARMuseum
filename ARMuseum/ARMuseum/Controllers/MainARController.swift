//
//  MainARController.swift
//  ARMuseum
//
//  Created by Dron on 23.04.2020.
//  Copyright © 2020 dron. All rights reserved.
//

import UIKit
import ARKit
import Vision

class MainARController: UIViewController {
    
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var audioView: UIView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var mapImageView: UIImageView!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var listButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.audioView.layer.cornerRadius = 10
        self.playButton.layer.cornerRadius = 10
        self.pauseButton.layer.cornerRadius = 10
        self.mapImageView.layer.cornerRadius = 10
        self.settingsButton.layer.cornerRadius = 10
        self.listButton.layer.cornerRadius = 10
        
        self.sceneView.delegate = self
        self.sceneView.session.delegate = self
        self.sceneView.showsStatistics = false
        self.sceneView.debugOptions = [.showFeaturePoints]
        
        let scene = SCNScene()
        sceneView.scene = scene
        
        //        self.initCoachingOverlayView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // World tracking
        let configuration = ARWorldTrackingConfiguration()
        
        let models = ARReferenceObject.referenceObjects(inGroupNamed: "models", bundle: nil)!
        configuration.detectionObjects = models
        
        let triggerImages = ARReferenceImage.referenceImages(inGroupNamed: "imageTriggers", bundle: nil)
        configuration.detectionImages = triggerImages
        configuration.maximumNumberOfTrackedImages = 1
        
        configuration.worldAlignment = .camera
        
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    func createCardOverlayNode(for anchor: ARImageAnchor) -> SCNNode {
        let box = SCNBox(
            width: anchor.referenceImage.physicalSize.width, height: 0.0001,
            length: anchor.referenceImage.physicalSize.height, chamferRadius: 0)
        if let material = box.firstMaterial {
            material.diffuse.contents = UIColor.red
            material.transparency = 0.3
        }
        return SCNNode(geometry: box)
    }
    
    func removeARPlaneNode(node: SCNNode) {
      for childNode in node.childNodes {
        childNode.removeFromParentNode()
      }
    }
    
}

extension MainARController: ARSessionDelegate {
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        
    }
}

extension MainARController : ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        if let objectAnchor = anchor as? ARObjectAnchor {
            handleFoundObject(node, objectAnchor)
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
      guard anchor is ARPlaneAnchor else { return }
      DispatchQueue.main.async {
        self.removeARPlaneNode(node: node)
      }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        if let anchor = anchor as? ARObjectAnchor {
            print("Found 3D object: \(anchor.referenceObject.name!)")
            return SCNNode()
        } else if let anchor = anchor as? ARImageAnchor {
            let overlayNode = createCardOverlayNode(for: anchor)
            return overlayNode
        }
        return nil
    }
}

extension MainARController {
    func handleFoundObject(_ node: SCNNode, _ anchor: ARObjectAnchor) {
        if let name = anchor.referenceObject.name, name == "airpods" {
            print("You found a \(name) object")
            let titleNode = createTitleNode(info: "А ВОТ У КСЯОМІ ЛУДШЕ....\n І ДЕШЕВШЕ!!!")
            node.addChildNode(titleNode)
        }
        
    }
    
    private func createTitleNode(info: String) -> SCNNode {
        let title = SCNText(string: info, extrusionDepth: 1.0)
        let titleNode = SCNNode(geometry: title)
        titleNode.scale = SCNVector3(0.005, 0.005, 0.005)
        titleNode.position = SCNVector3(-0.5, 0.1, 0.0)
        return titleNode
    }
    
}

extension MainARController {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let currentFrame = sceneView.session.currentFrame else { return }
        
        DispatchQueue.global(qos: .background).async {
            do {
                let request = VNDetectBarcodesRequest { (request, error) in
                    guard let results = request.results?.compactMap({ $0 as? VNBarcodeObservation }), let result = results.first else {
                        print ("[Vision] VNRequest produced no result")
                        return
                    }
                    
                    if let payload = result.payloadStringValue {
                        //TODO: add virtual object
                    }                    
                    
                }
                
                let handler = VNImageRequestHandler(cvPixelBuffer: currentFrame.capturedImage)
                try handler.perform([request])
            } catch(let error) {
                print("An error occurred during rectangle detection: \(error)")
            }
        }
    }
}
