//
//  ExhibitsManager.swift
//  ARMuseum
//
//  Created by Dron on 10.05.2020.
//  Copyright © 2020 dron. All rights reserved.
//

import UIKit

class ExhibitsManager {
    
    static let shared = ExhibitsManager()

    private var exhibits: [String:VirtualInfo] = [
        "f1InMonaco":VirtualInfo(text: "F1 ON MONACO BOOOOOY", images: [UIImage(named: "mapImage"), UIImage(named: "f1InMonaco")], audio: "f1music", videoLink: nil),
        "restingMan":VirtualInfo(text: "I NEED SOME REST TOOOOO", images: [], audio: nil, videoLink: nil)
    ]
    
    func findExhibitInfo(exhibitName: String) -> VirtualInfo? {
        let exhibit = exhibits[exhibitName]
        return exhibit
    }
    
}
