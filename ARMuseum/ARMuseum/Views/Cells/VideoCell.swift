/// Copyright (c) 2019 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit
import SpriteKit
import AVFoundation
import ARKit

class VideoCell: UICollectionViewCell {
    var isPlaying = false
    var videoNode: SKVideoNode!
    var spriteScene: SKScene!
    var videoUrl: String!
    var player: AVPlayer?
    weak var arInfoContainer: ARInfoContainer?
    weak var sceneView: ARSCNView?
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var playerContainer: UIView!
    @IBOutlet var containerViewWidth: NSLayoutConstraint!
    @IBOutlet var containerViewHeight: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.containerViewWidth.constant = UIScreen.main.bounds.width
        self.containerViewHeight.constant = UIScreen.main.bounds.height
    }
    
    func configure(videoUrl: String, sceneView: ARSCNView, arInfoContainer: ARInfoContainer) {
        self.videoUrl = videoUrl
        self.arInfoContainer = arInfoContainer
        self.sceneView = sceneView
        arInfoContainer.videoNodeHandler = self
    }
    
    func createVideoPlayerAnchor() {
        guard let billboard = arInfoContainer else { return }
        guard let sceneView = sceneView else { return }
        
        let center = billboard.anchor.transform * matrix_float4x4(SCNMatrix4MakeRotation(Float.pi / 2.0, 0, 0, 1))
        let anchor = ARAnchor(transform: center)
        sceneView.session.add(anchor: anchor)
        billboard.videoAnchor = anchor
    }
    
    func createVideoPlayerView() {
        if player == nil {
            guard let url = URL(string: videoUrl) else { return }
            player = AVPlayer(url: url)
            let layer = AVPlayerLayer(player: player)
            layer.frame = playerContainer.bounds
            playerContainer.layer.addSublayer(layer)
        }
        
        player?.play()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let billboard = arInfoContainer else { return }
        
        if billboard.isFullScreen {
            if isPlaying == false {
                createVideoPlayerView()
                //                playButton.setImage(#imageLiteral(resourceName: "arKit-pause"), for: .normal)
            } else {
                stopVideo()
                //                playButton.setImage(#imageLiteral(resourceName: "arKit-play"), for: .normal)
            }
            isPlaying = !isPlaying
        } else {
            createVideoPlayerAnchor()
            billboard.videoPlayerDelegate?.didStartPlay()
            //                    playButton.isEnabled = false
        }
    }
    
    func stopVideo() {
        player?.pause()
    }
    
    @IBAction func play(_ sender: UIButton) {
        guard let billboard = arInfoContainer else { return }
        
        if billboard.isFullScreen {
            if isPlaying == false {
                createVideoPlayerView()
                //                playButton.setImage(#imageLiteral(resourceName: "arKit-pause"), for: .normal)
            } else {
                stopVideo()
                //                playButton.setImage(#imageLiteral(resourceName: "arKit-play"), for: .normal)
            }
            isPlaying = !isPlaying
        } else {
            if isPlaying == false {
                billboard.videoPlayerDelegate?.didStartPlay()
                playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            } else {
                billboard.videoPlayerDelegate?.pausePlay()
                playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
            }
            isPlaying = !isPlaying
//            createVideoPlayerAnchor()
//            billboard.videoPlayerDelegate?.startPlay()
            
            //            playButton.isEnabled = false
        }
    }
}

extension VideoCell: VideoNodeHandler {
    func createNode() -> SCNNode? {
        guard let billboard = arInfoContainer else { return nil }
        var node: SCNNode!
        let url = URL(string: videoUrl)!
        
        let player = AVPlayer(url: url)
        let videoNode = SKVideoNode(avPlayer: player)
        videoNode.pause()
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
        var plane = SCNPlane(width: 100, height: 100)
        if let imageAnchor = billboard.anchor as? ARImageAnchor {
            plane = SCNPlane(width: imageAnchor.referenceImage.physicalSize.width, height: imageAnchor.referenceImage.physicalSize.height)
        } else if let objectAnchor = billboard.anchor as? ARObjectAnchor {
            plane = SCNPlane(width: CGFloat(objectAnchor.referenceObject.extent.x * 0.9), height: CGFloat(objectAnchor.referenceObject.extent.y * 1.8))
        }
        // set the first materials content to be our video scene
        plane.firstMaterial?.diffuse.contents = videoScene
        // create a node out of the plane
        let planeNode = SCNNode(geometry: plane)
        // since the created node will be vertical, rotate it along the x axis to have it be horizontal or parallel to our detected image
        planeNode.eulerAngles.x = -Float.pi / 2
        // finally add the plane node (which contains the video node) to the added node
        node.addChildNode(planeNode)
        return node
    }
    
    func removeNode() {
        videoNode?.pause()
        
        spriteScene?.removeAllChildren()
        spriteScene = nil
        
        if let videoAnchor = arInfoContainer?.videoAnchor {
            sceneView?.session.remove(anchor: videoAnchor)
        }
        
        arInfoContainer?.videoPlayerDelegate?.didEndPlay()
        
        arInfoContainer?.videoNode?.removeFromParentNode()
        arInfoContainer?.videoAnchor = nil
        arInfoContainer?.videoNode = nil
        
        //        playButton.isEnabled = true
    }
}
