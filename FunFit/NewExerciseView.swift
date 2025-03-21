//
//  NewExercise.swift
//  FunFit
//
//  Created by Jon Malachowski on 3/16/25.
//

import SwiftUI
import SwiftData
import Combine

struct NewExerciseView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var newExerciseName = ""
    @State private var newExerciseUnits = ""
    @State private var newExerciseFactor = 1
    
    let numformatter: NumberFormatter = {
           let formatter = NumberFormatter()
           formatter.numberStyle = .decimal
           return formatter
       }()

    var body: some View {
        Form {
            Section("New Exercise") {
                VStack {
                    HStack {
                        Text("Name:")
                        TextField("e.g. run",text: $newExerciseName).textFieldStyle(.roundedBorder)
                    }
                    HStack {
                        Text("Units:")
                        TextField("e.g. 'steps'",text: $newExerciseUnits)
                            .textFieldStyle(.roundedBorder)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .textCase(.lowercase)
                    }
                    HStack {
                        Text("How many " + newExerciseUnits + " per exercise")
                        //TextField("e.g. 5000", value: $newExerciseFactor, format: .number )
                        TextField("e.g. 5000", value: $newExerciseFactor, formatter: numformatter )
                            .textFieldStyle(.roundedBorder)
                            .keyboardType(.decimalPad)
                            /*.onReceive(Just(newExerciseFactor)) { newValue in
                                            let filtered = newValue.filter { "0123456789".contains($0) }
                                            if filtered != newValue {
                                                self.numOfPeople = filtered
                                            }
                                        }
                             */
                        
                    }
                    Button("Add Exercise", systemImage: "person.badge.plus", action: {
                        do {
                            let exercises = try modelContext.fetch(FetchDescriptor<Exercise>())
                            if !exercises.contains(where: { $0.name == newExerciseName } ) {
                                let newExercise = Exercise(
                                    name: newExerciseName,
                                    units: newExerciseUnits,
                                    num_per_point: newExerciseFactor
                                )
                                modelContext.insert( newExercise )
                                try modelContext.save()
                            }
                        } catch {
                            print("Failed to initialize new Exercise")
                        }
                        dismiss()
                    }).buttonStyle(.borderedProminent).tint(.green).padding()
                } //Vstack
            }
        } // form
    } // body
}

#Preview {
    NewExerciseView()
}

/*
enum NumericTextInputMode {
    case number,decimal
}

struct NumericTextInputViewModifier: ViewModifier {
    @Binding var text: String
    let mode: NumericTextInputMode
    func body(content: Content) -> some View {
        content
            .keyboardType(mode == .number ? .numberPad : .decimalPad)
            .onChange(of: text) { _, newValue in
                let decSeperator = Locale.current.decimalSeparator ?? "."
                let numbers = "0123456789\( mode == .decimal ? decSeperator: "" )"
                if newValue.components(separatedBy: decSeperator).count - 1 > 1 {
                    text = String(newValue.dropLast())
                } else {
                    let filtered = newValue.filter{ numbers.contains($0) }
                    if filtered != newValue {
                        text = newValue
                    }
                }
            }
    }
}

extension View {
    func numericTextInput(mode: NumericTextInputMode = .decimal, text: Binding<String> ) -> some View {
        modifier( NumericTextInputViewModifier( text: text, mode: mode ) )
    }
}
*/
