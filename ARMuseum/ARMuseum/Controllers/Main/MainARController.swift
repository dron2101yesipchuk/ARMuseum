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
    
    var arInfoContainer: ARInfoContainer?
    var audioManager: AudioManager?
    let feedbackGenerator = UINotificationFeedbackGenerator()
    var videoNode: SKVideoNode?
    var videoPlayer: AVPlayer?
    
    var isBlindModeOn: Bool = false {
        didSet {
            self.configureBlindMode()
        }
    }
    
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
        self.configureBlindMode()
        
        self.sceneView.delegate = self
        self.sceneView.showsStatistics = false
        //        self.sceneView.debugOptions = [.showFeaturePoints]
        
        self.sceneView.autoenablesDefaultLighting = true
        self.sceneView.automaticallyUpdatesLighting = true
        
        let scene = SCNScene()
        self.sceneView.scene = scene
    }
    
    func configureBlindMode() {
        self.feedbackGenerator.prepare()
        self.audioView.isHidden = self.isBlindModeOn
        self.playButton.isHidden = self.isBlindModeOn
        self.pauseButton.isHidden = self.isBlindModeOn
        self.mapImageView.isHidden = self.isBlindModeOn
        self.listButton.isHidden = self.isBlindModeOn
        self.scanQRButton.isHidden = self.isBlindModeOn
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
            arVC.sceneView = self.sceneView
            
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
            self.arInfoContainer?.videoNodeHandler = nil
            self.arInfoContainer = nil
        }
    }
    
    func createVideoNode(imageAnchor: ARImageAnchor, node: SCNNode) {
        if let videoUrl = ExhibitsManager.shared.findExhibitInfo(exhibitName: imageAnchor.referenceImage.name ?? "")?.videoLink {
            let url = URL(string: videoUrl)!
            
            let player = AVPlayer(url: url)
            let videoNode = SKVideoNode(avPlayer: player)
            videoNode.play()
//            player.pause()
            videoNode.size = CGSize(width: 1024, height: 1024)
            // set the size (just a rough one will do)
            let videoScene = SKScene(size: CGSize(width: 1024, height: 1024))
            videoScene.scaleMode = .aspectFit
            // center our video to the size of our video scene
            videoNode.position = CGPoint(x: videoScene.size.width / 2, y: videoScene.size.height / 2)
            // invert our video so it does not look upside down
            videoNode.yScale = -1.0
            // add the video to our scene
            videoScene.addChild(videoNode)
            // create a plan that has the same real world height and width as our detected image
            let plane = SCNPlane(width: imageAnchor.referenceImage.physicalSize.width, height: imageAnchor.referenceImage.physicalSize.height)
            // set the first materials content to be our video scene
            plane.firstMaterial?.diffuse.contents = videoScene
            // create a node out of the plane
            let planeNode = SCNNode(geometry: plane)
            // since the created node will be vertical, rotate it along the x axis to have it be horizontal or parallel to our detected image
            planeNode.eulerAngles.x = -Float.pi / 2
            // finally add the plane node (which contains the video node) to the added node
            node.addChildNode(planeNode)
            
            self.videoPlayer = player
            self.videoPlayer?.pause()
        }
    }
}

extension MainARController : ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if !self.isBlindModeOn {
            feedbackGenerator.notificationOccurred(.success)
            if let objectAnchor = anchor as? ARObjectAnchor {
                self.showObjectInfo(objectAnchor: objectAnchor, node: node)
            } else if let imageAnchor = anchor as? ARImageAnchor {
                self.showImageInfo(imageAnchor: imageAnchor, node: node)
                self.createVideoNode(imageAnchor: imageAnchor, node: node)
            }
        } else {
            var name: String? = nil
            if let objectAnchor = anchor as? ARObjectAnchor {
                name = objectAnchor.referenceObject.name
            } else if let imageAnchor = anchor as? ARImageAnchor {
                name = imageAnchor.referenceImage.name
            }
            if let exhibitInfo = ExhibitsManager.shared.findExhibitInfo(exhibitName: name ?? "") {
                self.arInfoContainer = ARInfoContainer(anchor: anchor, plane: SCNPlane())
                self.arInfoContainer?.info = exhibitInfo
                NotificationsManager.shared.postAudioFoundNotification(exhibitInfo.audio != nil)
            }
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

extension MainARController: FoundAudioHandler {
    
    func audioFound(isHaveAudio: Bool) {
        if isHaveAudio {
            self.audioNameLabel.text = self.arInfoContainer?.info?.audio
            feedbackGenerator.notificationOccurred(.success)
        }
        
        self.audioView.isHidden = !isHaveAudio || self.isBlindModeOn
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

extension MainARController: VideoPlayerDelegate {
    func startPlay() {
        self.videoNode?.play()
    }
    
    func pausePlay() {
        self.videoPlayer?.pause()
    }
    
    func didStartPlay() {
//        self.arInfoContainer?.node?.isHidden = true
        self.videoPlayer?.play()
    }
    
    func didEndPlay() {
//        self.arInfoContainer?.node?.isHidden = false
    }
}

extension MainARController: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        dismiss(animated: true)
    }
}
