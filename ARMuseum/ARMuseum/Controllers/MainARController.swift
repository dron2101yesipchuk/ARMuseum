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
    @IBOutlet weak var audioNameLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    
    @IBOutlet weak var mapImageView: UIImageView!
    
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var listButton: UIButton!
    @IBOutlet weak var scanQRButton: UIButton!
    
    var arInfoContainer: ARInfoContainer?
    private var audioManager: AudioManager?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationsManager.shared.subscribeForAudioFind(self)
        
        self.audioView.layer.cornerRadius = 10
        self.playButton.layer.cornerRadius = 10
        self.pauseButton.layer.cornerRadius = 10
        self.mapImageView.layer.cornerRadius = 10
        self.settingsButton.layer.cornerRadius = 10
        self.listButton.layer.cornerRadius = 10
        
        self.pauseButton.isHidden = true
        
        self.sceneView.delegate = self
        self.sceneView.showsStatistics = false
        //        self.sceneView.debugOptions = [.showFeaturePoints]
        
        self.sceneView.autoenablesDefaultLighting = true
        self.sceneView.automaticallyUpdatesLighting = true
        
        let scene = SCNScene()
        self.sceneView.scene = scene
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
    
    
    //MARK: - Info Controller
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
    
    func createHostingController(for node: SCNNode, referenceImageName: String) {
        DispatchQueue.main.async {
            guard let arVC = self.storyboard?.instantiateViewController(withIdentifier: "InfoController") as? InfoController,
                let exhibitInfo = ExhibitsManager.shared.findExhibitInfo(exhibitName: referenceImageName) else {
                return
            }
            
            arVC.info = exhibitInfo
            self.arInfoContainer?.viewController = arVC
            self.arInfoContainer?.info = exhibitInfo
            NotificationsManager.shared.postAudioFoundNotification(exhibitInfo.audio != nil)
            arVC.arInfoContainer = self.arInfoContainer
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
          viewController.willMove(toParent: nil)
          viewController.view.removeFromSuperview()
          viewController.removeFromParent()
        }
        self.sceneView.session.remove(anchor: anchor)
        self.arInfoContainer?.node?.removeFromParentNode()
        self.arInfoContainer = nil
      }
    }
}

extension MainARController : ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if let objectAnchor = anchor as? ARObjectAnchor {
            self.showObjectInfo(objectAnchor: objectAnchor, node: node)
        } else if let imageAnchor = anchor as? ARImageAnchor {
            self.showImageInfo(imageAnchor: imageAnchor, node: node)
        }
    }

    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        if let imageAnchor = anchor as? ARImageAnchor {
            node.isHidden = !imageAnchor.isTracked
        } else if let _ = anchor as? ARObjectAnchor {
//            node.isHidden = anchor.is
        }
    }
    
}

//TODO: Great refactoring
extension MainARController {
    @IBAction func scanQR(_ sender: UIButton) {
        guard let currentFrame = sceneView.session.currentFrame else { return }

        DispatchQueue.global(qos: .background).async {
            do {
                let request = VNDetectBarcodesRequest { (request, error) in
                    guard let results = request.results?.compactMap({ $0 as? VNBarcodeObservation }), let result = results.first else {
                        print ("[Vision] VNRequest produced no result")
                        return
                    }

                    if let payload = result.payloadStringValue,
                        let virtualObject = VirtualObject.decode(from: payload) {
                        VirtualObjectsManager.shared.insert(item: virtualObject)
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

extension MainARController: FoundAudioHandler {
    
    func audioFound(isHaveAudio: Bool) {
        
        self.audioNameLabel.text = self.arInfoContainer?.info?.audio
        self.audioView.isHidden = !isHaveAudio
    }
    
    @IBAction func playAudio(_ sender: UIButton) {
        if let audioManager = self.audioManager {
            audioManager.play()
        } else if let audioName = self.arInfoContainer?.info?.audio {
            self.audioManager = AudioManager(withFileName: audioName)
            self.audioManager?.play()
        }
        
        self.playButton.isHidden = true
        self.pauseButton.isHidden = false
        
    }
    
    @IBAction func pauseAudio(_ sender: UIButton) {
        if let audioManager = self.audioManager {
            audioManager.pause()
            self.playButton.isHidden = false
            self.pauseButton.isHidden = true
        }
    }
}


