//
//  ImageInfoCell.swift
//  ARMuseum
//
//  Created by Dron on 08.05.2020.
//  Copyright © 2020 dron. All rights reserved.
//

import UIKit

class ImageInfoCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    override class func awakeFromNib() {
        super.awakeFromNib()
        
        
    }
    
    func configureWith(image: UIImage) {
        self.imageView.image = image
    }
    
}
