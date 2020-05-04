//
//  ViewController.swift
//  ARMuseum
//
//  Created by Dron on 05.03.2020.
//  Copyright © 2020 dron. All rights reserved.
//

import UIKit
import ARKit
import RealityKit

class ViewController: UIViewController {
    
    @IBOutlet var arView: ARView!
    var textAnchor: Experience.Text!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.arView.addCoaching()
//        self.arView.debugOptions = [.showFeaturePoints]
        let config = ARWorldTrackingConfiguration()
        self.arView.session.run(config, options: .removeExistingAnchors)
        self.arView.session.delegate = self
        
        self.textAnchor = try! Experience.loadText()
        arView.scene.anchors.append(self.textAnchor)
//        self.setupConfiguration()
    }
    
    func setupConfiguration() {
        arView.automaticallyConfigureSession = false
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        configuration.environmentTexturing = .automatic
        arView.session.run(configuration)
    }

}

extension ViewController: ARSessionDelegate {
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        for anchor in anchors {
            print(anchor.name)
        }
    }
}

extension ARView: ARCoachingOverlayViewDelegate {
    
    func addCoaching() {
        let coachingOverlay = ARCoachingOverlayView()
        coachingOverlay.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        coachingOverlay.goal = .tracking
        coachingOverlay.activatesAutomatically = true
        coachingOverlay.session = self.session
        coachingOverlay.delegate = self
        self.addSubview(coachingOverlay)
        
        coachingOverlay.translatesAutoresizingMaskIntoConstraints =
        false
        // 2
        NSLayoutConstraint.activate([ NSLayoutConstraint(
        item: coachingOverlay, attribute: .top, relatedBy: .equal,
        toItem: self, attribute: .top, multiplier: 1, constant: 0),
        NSLayoutConstraint(
        item: coachingOverlay, attribute: .bottom,
        relatedBy: .equal,
        toItem: self, attribute: .bottom, multiplier: 1,
        constant: 0),
          NSLayoutConstraint(
        item: coachingOverlay, attribute: .leading, relatedBy: .equal,
        toItem: self, attribute: .leading, multiplier: 1, constant: 0),
        NSLayoutConstraint(
        item: coachingOverlay, attribute: .trailing,
        relatedBy: .equal,
        toItem: self, attribute: .trailing, multiplier: 1,
        constant: 0)
        ])
    }
    
    public func coachingOverlayViewDidDeactivate(_ coachingOverlayView: ARCoachingOverlayView) {
        
    }
    
    
    
}
