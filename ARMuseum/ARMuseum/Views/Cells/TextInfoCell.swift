//
//  TextInfoCell.swift
//  ARMuseum
//
//  Created by Dron on 07.05.2020.
//  Copyright © 2020 dron. All rights reserved.
//

import UIKit

class TextInfoCell: UICollectionViewCell {
    
    @IBOutlet weak var textView: UITextView!
    
    override class func awakeFromNib() {
        super.awakeFromNib()
        
        
    }
    
    func configureWith(text: String) {
        self.textView.text = text
    }
    
}
