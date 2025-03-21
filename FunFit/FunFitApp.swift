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
            Exercise.self, Workout.self, Settings.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            let modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
            let mainContext = modelContainer.mainContext
            let mySettingsArr = try mainContext.fetch(FetchDescriptor<Settings>())
            if mySettingsArr.isEmpty {
                print("Initializing Settings")
                let mySettings = Settings()
                mainContext.insert( mySettings )
                try mainContext.save()
                print("Initializing Settings Done")
            } else {
                let mySettings = mySettingsArr.first
                print("Loaded settings (\( mySettings!.current_points )/\( mySettings!.lifetime_points ))")
            }
            return modelContainer
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
