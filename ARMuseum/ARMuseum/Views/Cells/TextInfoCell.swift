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
    @IBOutlet var textViewWidth: NSLayoutConstraint!
    @IBOutlet var textViewHeight: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.textViewWidth.constant = UIScreen.main.bounds.width
        self.textViewHeight.constant = UIScreen.main.bounds.height
    }
    
    func configureWith(text: String) {
        self.textView.text = text
        self.textView.backgroundColor = .white
        self.textView.textColor = .black
    }
    
}
