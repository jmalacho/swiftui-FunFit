//
//  ContentView.swift
//  FunFit
//
//  Created by Jon Malachowski on 3/16/25.
//  https://developer.apple.com/documentation/charts
//

import SwiftUI
import SwiftData
//import SwiftUIIntrospect

enum TabPosition: Hashable {
    case logexercise
    case myexercises
    case relax
    case test
}

@MainActor
struct MainView: View {
    static let formatter = RelativeDateTimeFormatter()
    @State var secret_sequence_i = 0
    let secret_sequence : [ TabPosition ] = [ .myexercises, .logexercise, .myexercises, .logexercise, .relax ]
    @State public var selectedTab = TabPosition.logexercise
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Exercise.name, order: .forward) public var exercises : [Exercise]
    @Query(sort: \Workout.date, order: .reverse ) public var workouts : [Workout]
    @Query() public var settings : [Settings]
    @State private var newExerciseShowing = false
    @State private var newWorkoutShowing = false
    @State var jon = true
    @State var dt = Date.now
    @State var testingTabEnabled = false
    
    init() {
        MainView.formatter.unitsStyle = .abbreviated
        MainView.formatter.dateTimeStyle = .named
    }
    
    public func splitWorkouts( age: String) -> [Workout] {
        return self.workouts.filter( { workout in
            switch age {
            case "today":
                return workout.date >= Calendar(identifier: .gregorian).startOfDay(for: .now)
            case "this week":
                return ( Date().mondayOfTheSameWeek ... Calendar(identifier: .gregorian).startOfDay(for: .now) ).contains( workout.date )
                //return (Date.now ... Calendar.current.date(byAdding: .month, value: 1, to: Date.now)!).contains( goal.evaluationDate )
            case "older":
                return workout.date <= Date().mondayOfTheSameWeek
            default:
                return false
            }
        } )
    }
    
    struct WorkoutSection: View {
        @State var isExpanded : Bool
        private var age : String
        private var myWorkouts : [Workout]
        init(age : String, myWorkouts : [Workout], isExpanded: Bool = true) {
            self.age = age
            self.myWorkouts = myWorkouts
            self.isExpanded = isExpanded
        }
        
        var body: some View {
            Section( isExpanded: $isExpanded, content: {
                ForEach( myWorkouts ) { workout in
                    NavigationLink( destination: WorkoutDetailsView( workout: workout ) ) {
                        HStack {
                            Text( "\( age != "today" ? formatter.localizedString(for: workout.date, relativeTo: Date.now) + ":" : "" )  \(workout.quantity)\(workout.exercise_units != "" ? " " : "")\(workout.exercise_units) \(workout.exercise_name)" )
                        }
                        Spacer()
                        Text(" (\(workout.points))")
                            .foregroundStyle(.green)
                    }
                }
                /*.refreshable {
                 dt = Date.now
                 print("Refreshed?")
                 }.onAppear() {
                 dt = Date.now
                 }*/
            },
                     header: {
                Text(age).onTapGesture {
                    isExpanded.toggle()
                }.fontWeight( isExpanded ? .regular : .bold )
            })
        }
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            Tab( "Log Workout", systemImage: "calendar.badge.plus", value: .logexercise  ) {
                VStack {
                    Text("🚴 My Workouts 🏋️").font(.largeTitle).padding()
                    
                    NavigationStack {
                        List{
                            ForEach(["today","this week","older"], id:\.self) { age in
                                if splitWorkouts( age: age).count > 0 {
                                    WorkoutSection( age:age,
                                                    myWorkouts: splitWorkouts(age: age),
                                                    isExpanded: age != "older" )
                                }
                            } //for each age
                        } //list
                        Spacer()
                        ZStack {
                            Image("WorkoutBackground").resizable().scaledToFit()
                            VStack {
                                Spacer()
                                Button("Log *new* Workout", systemImage: "plus.app", action: {
                                    print("Button Pressed")
                                    if exercises.isEmpty {
                                        selectedTab = TabPosition.myexercises
                                    } else {
                                        newWorkoutShowing = true
                                    }
                                    print(newWorkoutShowing)
                                }).buttonStyle(.borderedProminent).tint(.green).padding()
                            } // VStack
                        } //ZStack
                    }.scrollContentBackground(.hidden)
                        .presentationBackground(.ultraThinMaterial)
                    //Text("footer")                .background(Image("WorkoutBackground").resizable().edgesIgnoringSafeArea(.all).aspectRatio(contentMode: .fit).frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
                    
                }.sheet(isPresented: $newWorkoutShowing) { NewWorkoutView() }
            } //Tab
            
            Tab( "Create Exercises", systemImage: "figure.run", value: .myexercises  ) {
                VStack {
                    Text("⚽️ Exercise List 🏸").font(.largeTitle).padding()
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
                }
                .sheet(isPresented: $newExerciseShowing) {
                    NewExerciseView()
                }
            }
            
            Tab( "Relax", systemImage: "gamecontroller", value: .relax  ) {
                VStack {
                    Text("🎮 Relax 🍻").font(.largeTitle).padding()
                    if !settings.isEmpty {
                        Text("Current points: \(settings.first!.current_points)")
                    }
                    Spacer()
                    HStack{ Spacer()
                        Button {
                            print("Relaxation requested")
                            playOpenBeer()
                            settings.first!.current_points -= 1
                            if settings.first!.current_points <= 0 {
                                selectedTab = TabPosition.logexercise
                            }
                        } label: {
                            Image("Beer")
                        }.buttonStyle(.bordered)
                        Spacer()
                    }.padding()
                } //Vstack
                .background(
                    Image("RelaxBackground")
                        .resizable()
                        .edgesIgnoringSafeArea(.all)
                        .aspectRatio(contentMode: .fit)
                        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                )
            }
            if testingTabEnabled {
                Tab( "Test", systemImage: "testtube.2", value: .test  ) {
                    HStack {
                        Spacer()
                        VStack {
                            Spacer()
                            Button("PlayOpenBeer", systemImage:"testtube.2",action: {
                                playOpenBeer()
                            }).buttonStyle(.bordered).padding()
                            Button("Hide Testing", systemImage:"testtube.2",action: {
                                testingTabEnabled = false
                            }).buttonStyle(.bordered).padding()
                            Spacer()
                        }
                        Spacer()
                    }
                } //Tab
            }
        }.onChange(of: selectedTab, initial: true) { _,arg  in
            dt = Date.now
            if selectedTab == secret_sequence[secret_sequence_i] {
                secret_sequence_i+=1
                if secret_sequence_i == secret_sequence.count {
                    playOpenBeer()
                    secret_sequence_i = 0
                    testingTabEnabled = true
                }
            } else {
                secret_sequence_i = 0
            }
            print( secret_sequence_i )
            
            if let s = settings.first {
                if (selectedTab == TabPosition.relax && s.current_points <= 0) {
                    selectedTab = TabPosition.logexercise
                }
            }
        }
    } //Body
                    
} //MainView

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
    return MainView().modelContainer(container)
}

/*
 
 */
