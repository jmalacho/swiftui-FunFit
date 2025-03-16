//
//  Item.swift
//  FunFit
//
//  Created by Jon Malachowski on 3/16/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
