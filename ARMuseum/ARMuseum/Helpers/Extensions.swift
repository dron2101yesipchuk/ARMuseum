//
//  Extensions.swift
//  ARMuseum
//
//  Created by Dron on 07.05.2020.
//  Copyright © 2020 dron. All rights reserved.
//

import UIKit

extension UIView {
    
    func roundCorners(radius: Int = 10) {
        self.layer.cornerRadius = CGFloat(radius)
    }
    
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat = 10) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
    
    func makeShadow(shadowParams: (color: UIColor, opacity: Float, offset: CGSize, radius: CGFloat) = (UIColor.black, 1, .zero, 10)) {
        self.layer.shadowColor = shadowParams.color.cgColor
        self.layer.shadowOpacity = shadowParams.opacity
        self.layer.shadowOffset = shadowParams.offset
        self.layer.shadowRadius = shadowParams.radius
    }
    
    func makeBorder(borderParams: (color: UIColor, width: CGFloat)) {
        self.layer.borderColor = borderParams.color.cgColor
        self.layer.borderWidth = borderParams.width
    }
    
    enum ViewSide {
        case left, right, top, bottom
    }
    
    func makeBorder(toSides sides: [ViewSide], borderParams: (color: UIColor, width: CGFloat)) {
        
        let border = CALayer()
        border.backgroundColor = borderParams.color.cgColor
        
        for side in sides {
            switch side {
            case .left: border.frame = CGRect(x: frame.minX, y: frame.minY, width: borderParams.width, height: frame.height); break
            case .right: border.frame = CGRect(x: frame.maxX, y: frame.minY, width: borderParams.width, height: frame.height); break
            case .top: border.frame = CGRect(x: frame.minX, y: frame.minY, width: frame.width, height: borderParams.width); break
            case .bottom: border.frame = CGRect(x: frame.minX, y: frame.maxY, width: frame.width, height: borderParams.width); break
            }
        }
        
        layer.addSublayer(border)
    }
}


extension UIColor {
    convenience init(hex: String, alpha: CGFloat = 1.0) {
        let hexString: String = hex.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let scanner = Scanner(string: hexString)
        if (hexString.hasPrefix("#")) {
            scanner.scanLocation = 1
        }
        var color: UInt32 = 0
        scanner.scanHexInt32(&color)
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        let red = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue = CGFloat(b) / 255.0
        self.init(red:red, green:green, blue:blue, alpha:alpha)
    }
}

extension TimeInterval {
    
    var timeInMinutes: String {
        return String(format: "%02d:%02d", ((Int)(self)) / 60, ((Int)(self)) % 60)
    }
    
}
