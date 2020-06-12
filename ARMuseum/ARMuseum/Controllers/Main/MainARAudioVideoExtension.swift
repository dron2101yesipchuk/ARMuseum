//
//  MainARAudioVideoExtension.swift
//  ARMuseum
//
//  Created by Dron on 08.06.2020.
//  Copyright © 2020 dron. All rights reserved.
//

import UIKit

extension MainARController: FoundAudioHandler {
    
    func audioFound(isHaveAudio: Bool) {
        if isHaveAudio {
            self.audioNameLabel.text = self.arInfoContainer?.info?.audio
//            feedbackGenerator.notificationOccurred(.success)
        }
        
        self.playButton.isHidden = false
        self.pauseButton.isHidden = true
        
        self.audioView.isHidden = !isHaveAudio || self.isBlindModeOn
        if let audioName = self.arInfoContainer?.info?.audio {
            self.audioManager = AudioManager(withFileName: audioName)
            self.audioManager?.play()
            self.audioManager?.pause()
        }
        
    }
}

extension MainARController: VideoPlayerDelegate {
    func startPlay() {

    }
    
    func pausePlay() {
         self.arInfoContainer?.videoPlayer?.pause()
    }
    
    func didStartPlay() {
         self.arInfoContainer?.videoPlayer?.play()
         self.arInfoContainer?.videoNode?.isHidden = false
    }
    
    func didEndPlay() {
         self.arInfoContainer?.videoNode?.isHidden = true
    }
}
