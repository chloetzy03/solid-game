//
//  ContentView.swift
//  SOLID game
//
//  Created by Chloe Tay on 12/11/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            KitchenLevelView()
                .tabItem { Label("S", systemImage: "person.fill") }
            DishLevelView()
                .tabItem { Label("O", systemImage: "puzzlepiece.fill") }
            ScenarioLevelView(scenario: .liskov)
                .tabItem { Label("L", systemImage: "arrow.left.arrow.right") }
            ScenarioLevelView(scenario: .interfaceSegregation)
                .tabItem { Label("I", systemImage: "scissors") }
            ScenarioLevelView(scenario: .dependencyInversion)
                .tabItem { Label("D", systemImage: "bolt.fill") }
        }
    }
}

#Preview {
    ContentView()
}
