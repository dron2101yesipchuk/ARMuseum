//
//  InfoCollectionController.swift
//  ARMuseum
//
//  Created by Dron on 14.05.2020.
//  Copyright © 2020 dron. All rights reserved.
//

import UIKit
import ARKit

class InfoCollectionController: UICollectionViewController {
    
    var arInfoContainer: ARInfoContainer?
    private var info: VirtualInfo? {
        return arInfoContainer?.info
    }
    
    // MARK: UICollectionViewDataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
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
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            if let text = self.info?.text ,let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TextInfoCell", for: indexPath) as? TextInfoCell {
                cell.configureWith(text: text)
                return cell
            }
        } else if indexPath.section == 1 {
            if let image = self.info?.images[indexPath.item],
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageInfoCell", for: indexPath) as? ImageInfoCell {
                cell.configureWith(image: image)
                return cell
            }
        } else if indexPath.section == 2 {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoCell", for: indexPath) as? VideoCell {
                if let arInfoContainer = self.arInfoContainer {
                    cell.configure(arInfoContainer: arInfoContainer)
                }
                return cell
            }
        }
        
        return UICollectionViewCell()
    }
    
}

extension InfoCollectionController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
      return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
