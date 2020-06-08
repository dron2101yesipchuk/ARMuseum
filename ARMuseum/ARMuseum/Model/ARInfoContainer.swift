//
//  ARInfoContainer.swift
//  ARMuseum
//
//  Created by Dron on 07.05.2020.
//  Copyright © 2020 dron. All rights reserved.
//

import ARKit

protocol VideoNodeHandler: class {
  func createNode() -> SCNNode?
  func removeNode()
}

protocol VideoPlayerDelegate: class {
    func startPlay()
    func pausePlay()
  func didStartPlay()
  func didEndPlay()
}

class ARInfoContainer {
    var info: VirtualInfo?
    var anchor: ARAnchor
    var node: SCNNode?
    var plane: SCNPlane
    var viewController: InfoCollectionController?
    var videoNode: SCNNode?
    var videoPlayer: AVPlayer?
    
    weak var videoPlayerDelegate: VideoPlayerDelegate?
    
    init(anchor: ARAnchor, plane: SCNPlane) {
        self.plane = plane
        self.anchor = anchor
      }
}
