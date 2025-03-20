//
//  NewWorkout.swift
//  FunFit
//
//  Created by Jon Malachowski on 3/19/25.
//

import SwiftUI
import SwiftData

struct NewWorkoutView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Exercise.name, order: .forward) public var exercises : [Exercise]
    @State var myExercise : Exercise?
    @State var mySelected = ""
    @State var newWorkoutQuantity = 0
    
    let numformatter: NumberFormatter = {
           let formatter = NumberFormatter()
           formatter.numberStyle = .decimal
           return formatter
    }()
    
    var body: some View {
        Form {
            Section("New Workout") {
                VStack {
                    Picker("Exercise: ", selection: $mySelected) {
                       ForEach(exercises, id: \.self) {
                           Text($0.name)
                               .tag($0.name)
                       }
                    }.onChange(of: mySelected) {
                        myExercise = exercises.first(where: {$0.name == mySelected} )
                    }
                    if myExercise != nil {
                        HStack {
                            Text("\(myExercise!.units): ")
                            TextField("e.g. 5000", value: $newWorkoutQuantity, formatter: numformatter )
                                .textFieldStyle(.roundedBorder)
                        }
                        Button("Log Workout", systemImage: "calendar.badge.plus", action: {
                                //do {
                                    //let workouts = try modelContext.fetch(FetchDescriptor<Workout>())
                            let newWorkout = Workout( exercise: myExercise! )
                            newWorkout.quantity = newWorkoutQuantity
                            modelContext.insert( newWorkout )
                            dismiss() //newMemberShowing = false
                                /*} catch {
                                    print("Failed to initialize new workout")
                                    dismiss()
                                }*/
                            dismiss()
                        }).buttonStyle(.borderedProminent).tint(.green).padding()
                    }
                }
            }
        } //form
    }
}

#Preview {
    NewWorkoutView()
}
