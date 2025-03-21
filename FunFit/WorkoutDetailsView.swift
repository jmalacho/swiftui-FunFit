//
//  WorkoutDetailsView.swift
//  FunFit
//
//  Created by Jon Malachowski on 3/19/25.
//

import SwiftUI

struct WorkoutDetailsView: View {
    public var workout: Workout
    @State var editing = false
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State var myWorkoutQuantity = 1
    @State var myWorkoutDate = Date.now
    @State var myWorkoutName = ""
    @State var myWorkoutUnits = ""
    let formatter = DateFormatter()
    
    init(workout: Workout) {
        formatter.locale = Locale(identifier: "en_US")
        formatter.timeStyle = .none
        formatter.dateStyle = .short
        self.workout = workout
    }
    
    var body: some View {
        VStack {
            HStack { Text("Exercise Deatils").padding()
                Spacer()
                Button( action: {
                    editing=true
                    myWorkoutQuantity = workout.quantity
                    myWorkoutDate = workout.date
                    myWorkoutName = workout.exercise_name
                    myWorkoutUnits = workout.exercise_units
                }, label: { Text("Edit")}).tint(.blue).padding()
            }
            Text(workout.exercise_name).font(.title).padding()
            Text("On \( formatter.string(from: workout.date) ) you logged:")
            Text("\( workout.quantity ) \( workout.exercise_units )")
            Spacer()
            Button( action: {
                do {
                    modelContext.delete( workout )
                    try modelContext.save()
                } catch {
                    print("Failed to delete exercise")
                }
                dismiss()
            }, label: { Text("🗑️ Delete Exercise") }).tint(.red).buttonStyle(.borderedProminent)
        } //vstack
    }
}

/*
 #Preview {
 WorkoutDetailsView()
 }
 */
