//
//  DishLevelView.swift
//  SOLID game
//

import SwiftUI

struct DishLevelView: View {
    // "StateObject" = the screen owns the brain and redraws when it changes.
    @StateObject private var level = DishLevel()

    var body: some View {
        ZStack {
            LinearGradient(colors: [.yellow.opacity(0.35), .orange.opacity(0.3)],
                           startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 14) {
                    Text("Game O").font(.largeTitle.bold())
                    Text("Add new things without breaking old things").font(.title3.bold())
                        .multilineTextAlignment(.center)

                    Text("Boss: \"Add \(level.newDish) to the menu!\"\nPick a way to do it: drag a card onto the Chef (or tap the card, then tap the Chef).")
                        .font(.subheadline)
                        .multilineTextAlignment(.center)

                    chefBox

                    if level.verdict == nil {
                        methodCard(.editOldCode,
                                   title: "Edit the Chef's old code",
                                   detail: "Squeeze Sushi into what he already does")
                        methodCard(.newRecipeCard,
                                   title: "Add a new Sushi recipe card",
                                   detail: "Leave the old stuff alone")
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

    // The Chef and the dishes he knows. Red = broken, green = new.
    private var chefBox: some View {
        VStack(spacing: 8) {
            Text("Chef").font(.headline)
            HStack(spacing: 8) {
                ForEach(level.menu, id: \.self) { dish in
                    dishChip(dish)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(.white.opacity(0.85))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(level.selectedMethod != nil ? Color.orange : .clear,
                        style: StrokeStyle(lineWidth: 3, dash: [6]))
        )
        // Drop a dragged card here...
        .dropDestination(for: String.self) { items, _ in
            guard let raw = items.first, let method = AddMethod(rawValue: raw) else { return false }
            level.apply(method)
            return true
        }
        // ...or tap a card first, then tap the Chef.
        .onTapGesture {
            if let method = level.selectedMethod { level.apply(method) }
        }
    }

    private func dishChip(_ dish: String) -> some View {
        let isNew = dish == level.newDish
        let isBroken = level.oldDishesBroken && !isNew

        return Text(isBroken ? "\(dish) (broken)" : dish)
            .font(.subheadline.bold())
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isBroken ? Color.red.opacity(0.3) : (isNew ? Color.green.opacity(0.35) : Color.orange.opacity(0.25)))
            .clipShape(Capsule())
    }

    // A "way to add Sushi" you can drag onto the Chef.
    private func methodCard(_ method: AddMethod, title: String, detail: String) -> some View {
        VStack(spacing: 2) {
            Text(title).font(.subheadline.bold())
            Text(detail).font(.caption).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(.white.opacity(0.9))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(level.selectedMethod == method ? Color.pink : .clear, lineWidth: 3)
        )
        .draggable(method.rawValue)
        .onTapGesture {
            level.selectedMethod = (level.selectedMethod == method) ? nil : method
        }
    }

    // Shown only after the player gets it right.
    private var explanation: some View {
        VStack(spacing: 12) {
            Text("This is Open/Closed (O): open to new things, closed to editing old working code.")
                .font(.headline)
                .multilineTextAlignment(.center)

            CodeCard(
                title: "Wrong: edit the Chef every time",
                code: """
                func cook(_ dish: String) {
                    if dish == "Pizza" { }
                    else if dish == "Burger" { }
                    // new dish? edit HERE (risky!)
                }
                """,
                translation: "Every new dish means opening this function and risking Pizza and Burger."
            )

            CodeCard(
                title: "Correct: each dish is its own card",
                code: """
                protocol Dish { func cook() }

                struct Pizza: Dish { func cook() { } }
                struct Sushi: Dish { func cook() { } }  // new!

                class Chef {
                    func cook(_ dish: Dish) { dish.cook() }
                }
                """,
                translation: "A protocol is the recipe-card format. Any dish that follows it works with the Chef, and the Chef's code never changes."
            )

            Button("Play again") { level.reset() }
                .buttonStyle(.bordered)
        }
    }
}

#Preview {
    DishLevelView()
}
