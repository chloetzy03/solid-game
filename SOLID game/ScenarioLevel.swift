//
//  ScenarioLevel.swift
//  SOLID game
//

import Foundation
import Combine

// The "brain" for the L, I and D games: rules only, no drawing.
// Translation: the screen only DRAWS; this file only DECIDES.
@MainActor
final class ScenarioLevel: ObservableObject {
    let scenario: Scenario

    // "@Published" = the screen redraws whenever these change.
    @Published var selectedChoiceID: String?          // chosen by tapping (alternative to dragging)
    @Published private(set) var chosen: ScenarioChoice?
    @Published private(set) var verdict: Verdict?

    init(scenario: Scenario) {
        self.scenario = scenario
    }

    func choose(_ id: String) {
        guard chosen == nil,
              let choice = scenario.choices.first(where: { $0.id == id }) else { return }
        selectedChoiceID = nil
        chosen = choice
        verdict = Verdict(isCorrect: choice.isCorrect, message: choice.message)
    }

    func reset() {
        selectedChoiceID = nil
        chosen = nil
        verdict = nil
    }
}
