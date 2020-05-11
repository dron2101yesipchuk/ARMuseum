//
//  NotificationsManager.swift
//  DLP-Core
//
//  Created by Ra Man on 27.07.17.
//  Copyright © 2017 CEIT. All rights reserved.
//

import UIKit


protocol FoundAudioHandler: AnyObject {
    func audioFound(isHaveAudio: Bool)
}

enum Notifications: String, NotificationName {
    case AudioFound
}

protocol NotificationName {
    var name: Notification.Name { get }
}

extension RawRepresentable where RawValue == String, Self: NotificationName {
    var name: Notification.Name {
        get {
            return Notification.Name(self.rawValue)
        }
    }
}

class NotificationsManager: NSObject {
    
    static let shared = NotificationsManager()
    
    var observers = [Dictionary<String, AnyObject>]()
    
    private func isObserver(_ observer:AnyObject) -> Bool {
        for obs in observers {
            if let theObs = obs["observer"] {
                if theObs.isEqual(observer) {
                    return true
                }
            }
        }
        return false
    }
    
    private func observerFor(subscriber:AnyObject) -> Dictionary<String, AnyObject>?{
        for obs in observers {
            if let theSub = obs["subscriber"] {
                if theSub.isEqual(subscriber) {
                    return obs
                }
            }
        }
        return nil
    }
    
    func unsubscribeFromNotifications(subscriber:AnyObject) {
        if let observer = self.observerFor(subscriber: subscriber) {
            if let theObserver = observer["observer"] as? NSObjectProtocol {
                NotificationCenter.default.removeObserver(theObserver)
            }
        }
    }
    
    func addObserver(observer:AnyObject, subscriber:AnyObject) {
        var observeDict = Dictionary<String, AnyObject>()
        observeDict["observer"] = observer
        observeDict["subscriber"] = subscriber
        if (!self.isObserver(observer)) {
            self.observers.append(observeDict)
        }
    }
    
    func subscribeForAudioFind(_ subscriber: FoundAudioHandler) {
        let observer = NotificationCenter.default.addObserver(forName: Notifications.AudioFound.name, object: nil, queue: .main) { notification in
            subscriber.audioFound(isHaveAudio: notification.userInfo?["isHaveAudio"] as? Bool ?? false)
        }
        self.addObserver(observer: observer, subscriber: subscriber)
    }
    
    func postAudioFoundNotification(_ isHaveAudio: Bool) {
        NotificationCenter.default.post(name: Notifications.AudioFound.name, object: self, userInfo: ["isHaveAudio":isHaveAudio])
    }
}
