//
//  InfoController.swift
//  ARMuseum
//
//  Created by Dron on 07.05.2020.
//  Copyright © 2020 dron. All rights reserved.
//

import UIKit
import ARKit

class InfoController: UIViewController {
    
    static let storyboardId = "InfoController"
    
    @IBOutlet weak var fullScreenButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var sceneView: ARSCNView?
    var arInfoContainer: ARInfoContainer?
    weak var mainViewController: MainARController?
    weak var mainView: UIView?
    
    var info: VirtualInfo?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.isPagingEnabled = true
        if self.info == nil {
            self.info = VirtualInfo(name: "Anything", text: "kek", images: [], audio: nil, videoLink: nil)
            self.collectionView.reloadData()
        }
        
        self.collectionView.alpha = 0
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
            self.collectionView.alpha = 1
        }, completion: nil)
    }
    
    @IBAction func goFullScreen(_ sender: UIButton) {
        guard let billboard = arInfoContainer else { return }
        if billboard.isFullScreen {
          restoreFromFullScreen()
        } else {
          showFullScreen()
        }
    }
    
}

extension InfoController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:
            return self.info?.text != nil ? 1 : 0
        case 1:
            return self.info?.images.count ?? 0
        case 2:
            return self.info?.videoLink != nil ? 1 : 0
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            if let text = self.info?.text ,let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TextInfoCell", for: indexPath) as? TextInfoCell {
                cell.configureWith(text: text)
                return cell
            }
        } else if indexPath.section == 1 {
            if let image = self.info?.images[indexPath.item], let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageInfoCell", for: indexPath) as? ImageInfoCell {
                cell.configureWith(image: image)
                return cell
            }
        } else if indexPath.section == 2 {
            if let videoLink = self.info?.videoLink, let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoCell", for: indexPath) as? VideoCell {
                if let sceneView = self.sceneView,
                    let arInfoContainer = arInfoContainer {
                  cell.configure(videoUrl: videoLink, sceneView: sceneView, arInfoContainer: arInfoContainer)
                }
                return cell
            }
        }
        
        return UICollectionViewCell()
    }
}

extension InfoController: UICollectionViewDelegate {
    
}

extension InfoController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

extension InfoController {
  func showFullScreen() {
    guard let billboard = arInfoContainer else { return }
    guard billboard.isFullScreen == false else { return }

    guard let mainViewController = parent as? MainARController else { return }
    self.mainViewController = mainViewController
    mainView = view.superview

    willMove(toParent: nil)
    view.removeFromSuperview()
    removeFromParent()

    willMove(toParent: mainViewController)
    mainViewController.view.addSubview(view)
    mainViewController.addChild(self)

    self.arInfoContainer?.isFullScreen = true
  }

  func restoreFromFullScreen() {
    guard let billboard = arInfoContainer else { return }
    guard billboard.isFullScreen == true else { return }
    guard let mainViewController = mainViewController else { return }
    guard let mainView = mainView else { return }

    willMove(toParent: nil)
    view.removeFromSuperview()
    removeFromParent()

    willMove(toParent: mainViewController)
    mainView.addSubview(view)
    mainViewController.addChild(self)

    self.arInfoContainer?.isFullScreen = false
    self.mainViewController = nil
    self.mainView = nil
  }
}
