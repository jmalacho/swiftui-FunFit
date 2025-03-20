//
//  ContentView.swift
//  FunFit
//
//  Created by Jon Malachowski on 3/16/25.
//  2: Add fun
//  3: Log fun
// 

import SwiftUI
import SwiftData

enum TabPosition: Hashable {
    case logexercise
    case myexercises
    case relax
}

@MainActor
struct MainView: View {
    @State public var seletectedTab = TabPosition.logexercise
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Exercise.name, order: .forward) public var exercises : [Exercise]
    @Query(sort: \Workout.date, order: .reverse ) public var workouts : [Workout]
    @State private var newExerciseShowing = false
    @State private var newWorkoutShowing = false
    @State var formatter = RelativeDateTimeFormatter()
    @State var jon = true
    @State var dt = Date.now

    init() {
        formatter.unitsStyle = .abbreviated
        formatter.dateTimeStyle = .named
    }
    
    var body: some View {
        TabView(selection: $seletectedTab) {
            VStack {
                Text("My Workouts").font(.largeTitle).padding()
                NavigationStack {
                    List(workouts) { workout in
                        NavigationLink( destination: WorkoutDetailsView( workout: workout ) ) {
                        HStack {
                            Text( "\(formatter.localizedString(for: workout.date, relativeTo: dt)):  \(workout.quantity)\(workout.exercise.units != "" ? " " : "")\(workout.exercise.units) \(workout.exercise.name)" )
                            }
                            Spacer()
                            Text(" (1)")
                                .foregroundStyle(.green)
                        }
                    }.refreshable {
                        dt = Date.now
                        print("Refreshed?")
                    }.onAppear() {
                        dt = Date.now
                    }
                }
                Spacer()

                Button("Log *new* Workout", systemImage: "plus.app", action: {
                    newWorkoutShowing = true
                }).buttonStyle(.borderedProminent).tint(.green)
            }
            .onAppear {
                if exercises.isEmpty {
                    seletectedTab = TabPosition.myexercises
                }
            }.sheet(isPresented: $newWorkoutShowing) {
                NewWorkoutView()
            }
            .tabItem { Label( "Log Workout", systemImage: "calendar.badge.plus" ) }
            .tag( TabPosition.logexercise )

            VStack {
                Text("🏃 Exercise List 🏃").font(.largeTitle).padding()
                NavigationStack {
                    List(exercises) { exercise in
                        NavigationLink( destination: ExerciseDetailsView( exercise: exercise) ) {
                            HStack {
                                Text( exercise.name ).font(.title)
                            }
                        }
                    }
                }
                Spacer()
                Button("Define *new* Exercise", systemImage: "plus.app", action: {
                    newExerciseShowing = true
                }).buttonStyle(.borderedProminent).tint(.green)
            } //Vstack
            .sheet(isPresented: $newExerciseShowing) {
                NewExerciseView()
            }
            .tabItem { Label( "Create Exercises", systemImage:"figure.run") }
            .tag( TabPosition.myexercises )
            
            VStack {
                Text("🍻").font(.largeTitle)
            }.tabItem { Label("Relax", systemImage: "gamecontroller")}
        }.onChange(of: seletectedTab, initial: true) { _,arg  in
            dt = Date.now
        }
        //Tabview
    } //Body
} //MainView
 

#Preview {
    let e = Exercise(name: "Walking")
    e.units = "steps"
    e.num_per_point = 5000
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Exercise.self, configurations: config)
    container.mainContext.insert(e)
    return MainView().modelContainer(container)
}
