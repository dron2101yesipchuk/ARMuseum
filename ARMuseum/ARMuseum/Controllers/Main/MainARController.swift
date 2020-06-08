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
import SafariServices

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
    @IBOutlet weak var searchButton: UIButton!
    
    var arInfoContainer: ARInfoContainer?
    var audioManager: AudioManager?
    let feedbackGenerator = UINotificationFeedbackGenerator()
    
    var isBlindModeOn: Bool = false {
        didSet {
            self.configureBlindMode()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationsManager.shared.subscribeForAudioFind(self)
        
        self.audioView.layer.cornerRadius = 10
        self.mapImageView.layer.cornerRadius = 10
        self.settingsButton.layer.cornerRadius = 10
        self.scanQRButton.layer.cornerRadius = 10
        self.searchButton.layer.cornerRadius = 10
        self.listButton.layer.cornerRadius = 10
        
        self.configureBlindMode()
        
        self.sceneView.delegate = self
        self.sceneView.showsStatistics = false
        self.sceneView.autoenablesDefaultLighting = true
        self.sceneView.automaticallyUpdatesLighting = true
        let scene = SCNScene()
        self.sceneView.scene = scene
    }
    
    func configureBlindMode() {
        self.feedbackGenerator.prepare()
        
        self.mapImageView.isHidden = self.isBlindModeOn
        self.listButton.isHidden = self.isBlindModeOn
        self.scanQRButton.isHidden = self.isBlindModeOn
        self.searchButton.isHidden = self.isBlindModeOn
        
        if !self.isBlindModeOn, let audioManager = self.audioManager {
            self.audioView.isHidden = false
            self.playButton.isHidden = !audioManager.isPlaying
            self.pauseButton.isHidden = audioManager.isPlaying
        } else {
            self.audioView.isHidden = true
            self.playButton.isHidden = true
            self.pauseButton.isHidden = true
        }
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
}

extension MainARController: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        dismiss(animated: true)
    }
}
