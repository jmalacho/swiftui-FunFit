//
//  FunFitApp.swift
//  FunFit
//
//  Created by Jon Malachowski on 3/16/25.
//
// https://stackoverflow.com/questions/58733003/how-to-create-textfield-that-only-accepts-numbers
// https://www.youtube.com/watch?v=fvR4oztY87Q&ab_channel=Rebeloper-RebelDeveloper

import SwiftUI
import SwiftData

@main
struct FunFitApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Exercise.self, Workout.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            MainView()
        }
        .modelContainer(sharedModelContainer)
    }
}
