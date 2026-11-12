//
//  ScenarioLevelView.swift
//  SOLID game
//

import SwiftUI

struct ScenarioLevelView: View {
    // "StateObject" = the screen owns the brain and redraws when it changes.
    @StateObject private var level: ScenarioLevel

    init(scenario: Scenario) {
        _level = StateObject(wrappedValue: ScenarioLevel(scenario: scenario))
    }

    private var scenario: Scenario { level.scenario }

    var body: some View {
        ZStack {
            LinearGradient(colors: [.yellow.opacity(0.35), .orange.opacity(0.3)],
                           startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 14) {
                    Text("Game \(scenario.letter)").font(.largeTitle.bold())
                    Text(scenario.heading).font(.title3.bold())
                        .multilineTextAlignment(.center)

                    Text(scenario.intro)
                        .font(.subheadline)
                        .multilineTextAlignment(.center)

                    slotBox

                    if level.chosen == nil {
                        ForEach(scenario.choices) { choice in
                            choiceCard(choice)
                        }
                    }

                    if let verdict = level.verdict {
                        VerdictBox(verdict: verdict)

                        if verdict.isCorrect {
                            explanation
                        } else {
                            Button("Try again") { level.reset() }
                                .buttonStyle(.borderedProminent)
                        }
                    }
                }
                .padding()
            }
        }
    }

    // The scene: shows the situation and, once chosen, the card you dropped.
    private var slotBox: some View {
        VStack(spacing: 8) {
            Text(scenario.slotName).font(.headline)

            HStack(spacing: 8) {
                ForEach(scenario.slotItems, id: \.self) { item in
                    chip(item, color: Color.orange.opacity(0.25))
                }
                if let chosen = level.chosen {
                    chip(chosen.title, color: chosen.isCorrect ? Color.green.opacity(0.35) : Color.red.opacity(0.3))
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(.white.opacity(0.85))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(level.selectedChoiceID != nil ? Color.orange : .clear,
                        style: StrokeStyle(lineWidth: 3, dash: [6]))
        )
        // Drop a dragged card here...
        .dropDestination(for: String.self) { items, _ in
            guard let id = items.first else { return false }
            level.choose(id)
            return true
        }
        // ...or tap a card first, then tap the scene.
        .onTapGesture {
            if let id = level.selectedChoiceID { level.choose(id) }
        }
    }

    private func chip(_ text: String, color: Color) -> some View {
        Text(text)
            .font(.subheadline.bold())
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(color)
            .clipShape(Capsule())
    }

    // A card you can drag onto the scene.
    private func choiceCard(_ choice: ScenarioChoice) -> some View {
        VStack(spacing: 2) {
            Text(choice.title).font(.subheadline.bold())
            Text(choice.detail).font(.caption).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(.white.opacity(0.9))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(level.selectedChoiceID == choice.id ? Color.pink : .clear, lineWidth: 3)
        )
        .draggable(choice.id)
        .onTapGesture {
            level.selectedChoiceID = (level.selectedChoiceID == choice.id) ? nil : choice.id
        }
    }

    // Shown only after the player gets it right.
    private var explanation: some View {
        VStack(spacing: 12) {
            Text(scenario.principle)
                .font(.headline)
                .multilineTextAlignment(.center)

            ForEach(scenario.examples.indices, id: \.self) { index in
                let example = scenario.examples[index]
                CodeCard(title: example.title, code: example.code, translation: example.translation)
            }

            Button("Play again") { level.reset() }
                .buttonStyle(.bordered)
        }
    }
}

#Preview {
    ScenarioLevelView(scenario: .liskov)
}
