//
//  WorkoutDetailsView.swift
//  FunFit
//
//  Created by Jon Malachowski on 3/19/25.
//

import SwiftUI
import SwiftData

struct WorkoutDetailsView: View {
    public var workout: Workout
    @State var editing = false
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query() public var settings : [Settings]
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
    
    let numformatter: NumberFormatter = {
           let formatter = NumberFormatter()
           formatter.numberStyle = .decimal
           return formatter
    }()
    
    var body: some View {
        VStack {
            HStack {
                Text("Exercise Deatils").padding()
                Spacer()
                if editing {
                    Button( action: {
                        editing=false
                    }, label: { Text("Cancel")}).tint(.blue).buttonStyle(.bordered).padding()
                } else {
                    Button( action: {
                        editing=true
                        myWorkoutQuantity = workout.quantity
                        myWorkoutDate = workout.date
                        myWorkoutName = workout.exercise_name
                        myWorkoutUnits = workout.exercise_units
                    }, label: { Text("Edit")}).tint(.blue).padding()
                }
            }
            if editing {
                HStack {
                    Text("\(myWorkoutUnits): ")
                    TextField("e.g. 5000", value: $myWorkoutQuantity, formatter: numformatter )
                        .textFieldStyle(.roundedBorder)
                }.padding()
                Button( action: {
                    settings.first!.current_points -= workout.points
                    settings.first!.lifetime_points -= workout.points
                    workout.quantity = myWorkoutQuantity
                    settings.first!.current_points += workout.points
                    settings.first!.lifetime_points += workout.points
                    editing=false
                }, label: { Text("Save")}).tint(.green).buttonStyle(.borderedProminent).padding()
                Spacer()
                Button( action: {
                    do {
                        settings.first!.current_points -= workout.points
                        settings.first!.lifetime_points -= workout.points
                        modelContext.delete( workout )
                        try modelContext.save()
                    } catch {
                        print("Failed to delete workout")
                    }
                    dismiss()
                }, label: { Text("🗑️ Delete Workout") }).tint(.red).buttonStyle(.borderedProminent)
                    .padding()
            } else {
                Text(workout.exercise_name).font(.title).padding()
                Text("On \( formatter.string(from: workout.date) ) you logged:")
                Text("\( workout.quantity ) \( workout.exercise_units )")
                Spacer()
                Text("\(workout.points) point\( workout.points == 1 ? "" : "s" )")
                    .font(.title)
                    .foregroundStyle(.green)
                Spacer()
            }
        } //vstack
    }
}




#Preview {
    let e = Exercise(name: "Walking", units: "steps", num_per_point: 5000)
    let s = Settings()
    s.current_points = 2
    let w = Workout(exercise: e)
    w.quantity = 10000
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Exercise.self, configurations: config)
    container.mainContext.insert(e)
    container.mainContext.insert(s)
    container.mainContext.insert(w)
    return WorkoutDetailsView( workout: w ).modelContainer(container)
}
