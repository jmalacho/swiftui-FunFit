//
//  ExerciseDetailsView.swift
//  FunFit
//
//  Created by Jon Malachowski on 3/17/25.
//

import SwiftUI
import SwiftData

struct ExerciseDetailsView: View {
    public var exercise: Exercise
    @Environment(\.dismiss) var dismiss
    @State var editing = false
    @Environment(\.modelContext) private var modelContext
    
    @State private var exerciseName = ""
    @State private var exerciseUnits = ""
    @State private var exerciseFactor = 1
    
    let numformatter: NumberFormatter = {
           let formatter = NumberFormatter()
           formatter.numberStyle = .decimal
           return formatter
       }()
    
    var body: some View {
        if editing {
            VStack {
                HStack { Text("Exercise Deatils").padding()
                    Spacer()
                    Button( action: {
                        editing=false
                    }, label: { Text("Cancel")}).tint(.blue).buttonStyle(.bordered).padding()
                }
                Spacer()
                VStack {
                    HStack {
                        Text("Name:")
                        TextField("e.g. run",text: $exerciseName).textFieldStyle(.roundedBorder)
                    }
                    HStack {
                        Text("Units:")
                        TextField("e.g. 'steps'",text: $exerciseUnits)
                            .textFieldStyle(.roundedBorder)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .textCase(.lowercase)
                    }
                    HStack {
                        Text("How many " + exerciseUnits + " per exercise")
                        TextField("e.g. 5000", value: $exerciseFactor, formatter: numformatter )
                            .textFieldStyle(.roundedBorder)
                            .keyboardType(.decimalPad)
                    }
                    Button( action: {
                        exercise.name = exerciseName
                        exercise.units = exerciseUnits
                        exercise.num_per_point = exerciseFactor
                        editing=false
                    }, label: { Text("Save")}).tint(.green).buttonStyle(.borderedProminent).padding()
                }.padding()
                Spacer()
            }
        } else {
            VStack {
                HStack { Text("Exercise Deatils").padding()
                    Spacer()
                    Button( action: {
                        editing=true
                        exerciseName = exercise.name
                        exerciseUnits = exercise.units
                        exerciseFactor = exercise.num_per_point
                    }, label: { Text("Edit")}).tint(.blue).padding()
                }
                Text(exercise.name).font(.title).padding()
                Text("\(exercise.num_per_point) \(exercise.units)")
                Spacer()
                Button( action: {
                    modelContext.delete( exercise )
                    dismiss()
                }, label: { Text("🗑️ Delete Exercise") }).tint(.red).buttonStyle(.borderedProminent)
            } //vstack
        } //editing
            
    }
}

#Preview {
    let e = Exercise(name: "Walking")
    e.units = "steps"
    e.num_per_point = 5000
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Exercise.self, configurations: config)
    container.mainContext.insert(e)
    return ExerciseDetailsView(exercise: e).modelContainer(container)
}
