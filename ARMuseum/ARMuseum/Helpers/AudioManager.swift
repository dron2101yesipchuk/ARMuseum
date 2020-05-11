//
//  AudioRecorder.swift
//  DirectAutoApp
//
//  Created by Dron on 28.02.2020.
//  Copyright © 2020 vallsoft. All rights reserved.
//

import AVFoundation

enum AudioRecorderState {
    case Pause
    case Play
    case Finish
    case Failed(String)
    case Recording
    case Ready
    case error(Error)
}
extension AudioRecorderState: Equatable {
    
    public static func ==(lhs: AudioRecorderState, rhs:AudioRecorderState) -> Bool {
        switch lhs {
        case .Failed(let rCause):
            switch rhs {
            case .Failed(let lCause):
                return rCause == lCause
            default:
                return false
            }
        case .error(_):
            switch rhs {
            case .error(_):
                return false
            default:
                return false
            }
        case .Pause:
            switch rhs {
            case .Pause:
                return true
            default:
                return false
            }
        case .Play:
            switch rhs {
            case .Play:
                return true
            default:
                return false
            }
        default:
            switch rhs {
            case .error(_):
                return false
            default:
                return false
            }
        }
    }
}

protocol AudioManagerDelegate {
    func agAudioRecorder(_ recorder: AudioManager, withStates state: AudioRecorderState)
    func agAudioRecorder(_ recorder: AudioManager, currentTime timeInterval: TimeInterval, formattedString: String)
    func audioPlayerDidFinishPlaying()
}

class AudioManager: NSObject {
    
    private var recorderState: AudioRecorderState = .Ready {
        willSet{
            delegate?.agAudioRecorder(self, withStates: newValue)
        }
    }
    private var playerState: AudioRecorderState = .Ready
    
    private var audioPlayer: AVAudioPlayer! = nil
    private var meterTimer: Timer! = nil
    private var currentTimeInterval: TimeInterval = 0.0
    
    var filename: String = ""
    var index: Int?
    var durationInSeconds: TimeInterval {
        return self.audioPlayer.duration
    }
    var duration: String {
        self.durationInSeconds.timeInMinutes
    }
    var isPlaying: Bool {
        self.audioPlayer.isPlaying
    }
    var currentTimePlaying: TimeInterval {
        self.audioPlayer.currentTime
    }
    var delegate: AudioManagerDelegate?
    
    init(withFileName filename: String) {
        super.init()
        
        self.recorderState = .Ready
        self.filename = filename
    }
    
    private func documentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    func fileUrl() -> URL {
        let filename = "\(self.filename)"
        let filePath = Bundle.main.url(forResource: filename, withExtension: "mp3") ?? documentsDirectory().appendingPathComponent(filename)
        return filePath
    }

    func changeFile(withFileName filename: String) {
        self.filename = filename

        if audioPlayer != nil {
            self.pause()
        }
    }
    
    private func preparePlay() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback)
            audioPlayer = try AVAudioPlayer(contentsOf: fileUrl())
            audioPlayer.delegate = self
            audioPlayer.prepareToPlay()
            recorderState = .Ready
        }
        catch {
            recorderState = .error(error)
            debugPrint(error)
        }
    }
    
    func play() {
        if audioPlayer == nil {
            self.preparePlay()
        }
        
        if audioPlayer.isPlaying {
            pause()
        } else {
            if self.playerState == AudioRecorderState.Pause {
                audioPlayer.play()
                recorderState = .Play
                playerState = .Play
            } else if FileManager.default.fileExists(atPath: fileUrl().path) {
                preparePlay()
                audioPlayer.play()
                recorderState = .Play
                playerState = .Play
            }
            else {
                recorderState = .Failed("Audio file is missing.")
            }
        }
    }
    
    func pause() {
        guard audioPlayer != nil else {
            return
        }
        
        if (audioPlayer.isPlaying){
            audioPlayer.pause()
        }
        recorderState = .Pause
        playerState = .Pause
    }
    
    func stopPlaying() {
        guard audioPlayer != nil else {
            return
        }
        
        audioPlayer.currentTime = 0
        audioPlayer.pause()
        recorderState = .Pause
        playerState = .Pause
    }
}

extension AudioManager: AVAudioPlayerDelegate {
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.delegate?.audioPlayerDidFinishPlaying()
    }
}
