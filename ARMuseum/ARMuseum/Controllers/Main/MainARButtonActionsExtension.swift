//
//  MainARButtonActionsExtension.swift
//  ARMuseum
//
//  Created by Dron on 18.05.2020.
//  Copyright © 2020 dron. All rights reserved.
//

import UIKit
import ARKit
import Vision
import SafariServices


extension MainARController {
    @IBAction func scanQR(_ sender: UIButton) {
        guard let currentFrame = sceneView.session.currentFrame else { return }
        
        DispatchQueue.global(qos: .background).async {
            do {
                let request = VNDetectBarcodesRequest { (request, error) in
                    guard let results = request.results?.compactMap({ $0 as? VNBarcodeObservation }), let result = results.first else {
                        print ("[Vision] VNRequest produced no result")
                        return
                    }
                    
                    if let payload = result.payloadStringValue,
                        let virtualObject = VirtualObject.decode(from: payload) {
                        VirtualObjectsManager.shared.insert(item: virtualObject)
                    }
                    
                }
                
                let handler = VNImageRequestHandler(cvPixelBuffer: currentFrame.capturedImage)
                try handler.perform([request])
            } catch(let error) {
                print("An error occurred during rectangle detection: \(error)")
            }
        }
    }
    
    @IBAction func searchInInternet(_ sender: UIButton) {
        guard let infoContainer = self.arInfoContainer, let info = infoContainer.info else {
            //TODO: Alert
            return
        }
        var textToSearch = info.name
        let allowedCharacters = NSCharacterSet.urlFragmentAllowed

        guard let encodedSearchString = textToSearch.addingPercentEncoding(withAllowedCharacters: allowedCharacters)  else {
            return
        }
        let queryString = "https://www.google.com/search?q=\(encodedSearchString)"
        if let url = URL(string: queryString) {
            let vc = SFSafariViewController(url: url, entersReaderIfAvailable: true)
            vc.delegate = self
            
            present(vc, animated: true)
        }
    }
    
    @IBAction func turnBlindOn(_ sender: UIButton) {
        self.isBlindModeOn = !self.isBlindModeOn
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if self.isBlindModeOn {
            if let audioManager = self.audioManager {
                if audioManager.isPlaying {
                    audioManager.pause()
                } else {
                    audioManager.play()
                }
            } else if let audioName = self.arInfoContainer?.info?.audio {
                self.audioManager = AudioManager(withFileName: audioName)
                self.audioManager?.play()
            }
        } else {
            
        }
    }
}
