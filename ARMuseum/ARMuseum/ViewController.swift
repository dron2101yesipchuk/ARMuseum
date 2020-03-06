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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load the "Box" scene from the "Experience" Reality File
        let boxAnchor = try! Experience.loadBox()
        
        // Add the box anchor to the scene
        self.arView.addCoaching()
        self.arView.scene.anchors.append(boxAnchor)
    }
    
    func setupConfiguration() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        
        self.arView.session.run(configuration)
    }

}

extension ARView: ARCoachingOverlayViewDelegate {
    
    func addCoaching() {
        let coachingOverlay = ARCoachingOverlayView()
        coachingOverlay.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        coachingOverlay.goal = .horizontalPlane
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
