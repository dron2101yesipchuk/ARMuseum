//
//  MapDetailedController.swift
//  ARMuseum
//
//  Created by Dron on 08.06.2020.
//  Copyright © 2020 dron. All rights reserved.
//

import UIKit

class MapDetailedController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var mapImageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapImageView.image = UIImage(named: "mapImage")
        
        self.scrollView.minimumZoomScale = 1.0
        self.scrollView.maximumZoomScale = 6.0
    }

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.mapImageView
    }
    
    @IBAction func closeAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}
