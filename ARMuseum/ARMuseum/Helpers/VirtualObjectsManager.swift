//
//  VirtualObjects.swift
//  ARMuseum
//
//  Created by Dron on 06.05.2020.
//  Copyright © 2020 dron. All rights reserved.
//

import Foundation

class VirtualObjectsManager {
    
    static let shared: VirtualObjectsManager = VirtualObjectsManager()
    
    private let defaults = UserDefaults.standard
    private let key = "VirtualObjectsList"
    var virtualObjects: [VirtualObject] = []
    
    
    func insert(item: VirtualObject) {
        let _ = self.retrieveItems()
        if !self.virtualObjects.contains(where: { $0.name == item.name }) {
            self.virtualObjects.append(item)
        }
        
        if let data = try? JSONEncoder().encode(self.virtualObjects) {
            defaults.set(data, forKey: self.key)
        }
    }
    
    func retrieveItems() -> [VirtualObject] {
        if let data = defaults.object(forKey: self.key) as? Data,
            let objects = try? JSONDecoder().decode([VirtualObject].self, from: data) {
            self.virtualObjects = objects
            return objects
        }
        return []
    }
    
}
