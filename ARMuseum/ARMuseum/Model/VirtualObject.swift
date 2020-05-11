//
//  VirtualObject.swift
//  ARMuseum
//
//  Created by Dron on 06.05.2020.
//  Copyright © 2020 dron. All rights reserved.
//

import Foundation
import UIKit

class VirtualObject: Codable {
    var image: String
    var name: String
    
    static func decode(from json: String) -> VirtualObject? {
        guard let jsonData = json.data(using: .utf8) else {
            return nil
        }

        return try? JSONDecoder().decode(VirtualObject.self, from: jsonData)
    }
}
