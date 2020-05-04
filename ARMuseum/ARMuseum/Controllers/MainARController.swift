//
//  MainARController.swift
//  ARMuseum
//
//  Created by Dron on 23.04.2020.
//  Copyright © 2020 dron. All rights reserved.
//

import UIKit
import ARKit

class MainARController: UIViewController, ARSessionDelegate {
    
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
        
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    func initCoachingOverlayView() {
        let coachingOverlay = ARCoachingOverlayView()
        coachingOverlay.session = self.sceneView.session
        coachingOverlay.activatesAutomatically = true
        coachingOverlay.goal = .horizontalPlane
        coachingOverlay.delegate = self
        self.sceneView.addSubview(coachingOverlay)
        
        coachingOverlay.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            NSLayoutConstraint(
                item:  coachingOverlay, attribute: .top, relatedBy: .equal,
                toItem: self.view, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(
                item:  coachingOverlay, attribute: .bottom, relatedBy: .equal,
                toItem: self.view, attribute: .bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(
                item:  coachingOverlay, attribute: .leading, relatedBy: .equal,
                toItem: self.view, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(
                item:  coachingOverlay, attribute: .trailing, relatedBy: .equal,
                toItem: self.view, attribute: .trailing, multiplier: 1, constant: 0)
        ])
    }
}

extension MainARController : ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if let objectAnchor = anchor as? ARObjectAnchor {
            handleFoundObject(node, objectAnchor)
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        if let anchor = anchor as? ARObjectAnchor {
            print("Found 3D object: \(anchor.referenceObject.name!)")
            return SCNNode()
        }
        return nil
    }
}

extension MainARController : ARCoachingOverlayViewDelegate {
    
    // MARK: - AR Coaching Overlay View
    
    func coachingOverlayViewWillActivate(_ coachingOverlayView: ARCoachingOverlayView) {
    }
    
    func coachingOverlayViewDidDeactivate(_ coachingOverlayView: ARCoachingOverlayView) {
    }
    
    func coachingOverlayViewDidRequestSessionReset(_ coachingOverlayView: ARCoachingOverlayView) {
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
