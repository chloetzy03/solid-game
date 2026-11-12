//
//  DishLevel.swift
//  SOLID game
//

import Foundation
import Combine

// The two ways the player can add Sushi.
enum AddMethod: String {
    case editOldCode    // open the Chef's old code (risky!)
    case newRecipeCard  // add a brand-new recipe card (safe!)
}

// The "brain" of Game O: rules only, no drawing.
// Translation: the screen only DRAWS; this file only DECIDES.
@MainActor
final class DishLevel: ObservableObject {
    // "@Published" = the screen redraws whenever these change.
    @Published private(set) var menu: [String] = []     // dishes the Chef knows
    @Published private(set) var oldDishesBroken = false
    @Published var selectedMethod: AddMethod?           // chosen by tapping (alternative to dragging)
    @Published private(set) var verdict: Verdict?

    let newDish = "Sushi"

    init() { reset() }

    func reset() {
        menu = ["Pizza", "Burger"]
        oldDishesBroken = false
        selectedMethod = nil
        verdict = nil
    }

    // The player picks HOW to add Sushi.
    func apply(_ method: AddMethod) {
        guard verdict == nil else { return }
        selectedMethod = nil
        menu.append(newDish)

        switch method {
        case .editOldCode:
            oldDishesBroken = true
            verdict = Verdict(isCorrect: false,
                              message: "You opened the Chef's old code to squeeze Sushi in, and now the Pizza has fish on it and the Burger is raw. Never edit code that already works!")
        case .newRecipeCard:
            verdict = Verdict(isCorrect: true,
                              message: "Sushi got its own recipe card. Pizza and Burger didn't even notice. Add 100 more dishes and the Chef's code never changes.")
        }
    }
}
