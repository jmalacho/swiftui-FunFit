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
    init(name: String, units: String, num_per_point: Int) {
        self.name = name
        self.units = units
        self.num_per_point = num_per_point
    }
}

@Model
final class Workout : Identifiable {
    var exercise_name = ""
    var exercise_units = ""
    var exercise_num_per_point = 1
    
    var date: Date = Date.now
    var quantity: Int = 1
    
    var points: Int {
        return quantity / exercise_num_per_point
    }
    
    init(exercise: Exercise) {
        self.exercise_name = exercise.name
        self.exercise_units = exercise.units
        self.exercise_num_per_point = exercise.num_per_point
    }
}

@Model
final class Settings : Identifiable {
    var current_points = 0
    var lifetime_points = 0
    init() {}
}

import AudioToolbox

func playOpenBeer() {
    let soundURL = Bundle.main.url(forResource: "opening-beer-can", withExtension: "mp3")!
    var soundID: SystemSoundID = 0
    AudioServicesCreateSystemSoundID(soundURL as CFURL, &soundID)
    AudioServicesPlaySystemSound(soundID)
}







extension Date {
    public enum Weekday: Int {
        case sunday = 1, monday, tuesday, wednesday, thursday, friday, saturday
    }
    
    public func next(_ weekday: Weekday,
                     direction: Calendar.SearchDirection = .forward,
                     considerToday: Bool = false) -> Date
    {
        let calendar = Calendar(identifier: .gregorian)
        let components = DateComponents(weekday: weekday.rawValue)

        if considerToday &&
            calendar.component(.weekday, from: self) == weekday.rawValue
        {
            return self
        }

        return calendar.nextDate(after: self,
                                 matching: components,
                                 matchingPolicy: .nextTime,
                                 direction: direction)!
    }
    
    var mondayOfTheSameWeek: Date {
        Date().next(.monday, direction: .backward)
        //Calendar(identifier:  .gregorian).dateComponents([.calendar, .yearForWeekOfYear, .weekOfYear], from: self).date!
    }
}
