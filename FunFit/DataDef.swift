//
//  DataDef.swift
//  FunFit
//
//  Created by Jon Malachowski on 3/16/25.
//


import Foundation
import SwiftData

@Model
final class Exercise : Identifiable {
    @Attribute(.unique) var name: String
    var num_per_point : Int = 1
    var units : String = ""
    init(name: String) {
        self.name   = name
    }
}

@Model
final class Workout : Identifiable {
    var date: Date = Date.now
    var exercise: Exercise
    var quantity: Int = 1
    init(exercise: Exercise  ) {
        self.exercise = exercise
    }
}
    
