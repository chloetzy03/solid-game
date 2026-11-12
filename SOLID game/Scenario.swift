//
//  Scenario.swift
//  SOLID game
//

import Foundation

// One card the player can drag onto the scene.
struct ScenarioChoice: Identifiable {
    let id: String
    let title: String
    let detail: String
    let isCorrect: Bool
    let message: String   // funny line shown after choosing
}

struct CodeExample {
    let title: String
    let code: String
    let translation: String
}

// Everything one game needs. A new game = new data, no new screen code.
struct Scenario {
    let letter: String
    let heading: String
    let intro: String
    let slotName: String
    let slotItems: [String]
    let choices: [ScenarioChoice]
    let principle: String
    let examples: [CodeExample]
}

extension Scenario {
    // L: replacements must do the same job as the original.
    static let liskov = Scenario(
        letter: "L",
        heading: "A replacement must do the same job",
        intro: "The Waiter is on holiday! Drag a replacement onto the Waiter's spot (or tap the card, then tap the spot).",
        slotName: "Waiter's spot",
        slotItems: ["Job: serve food"],
        choices: [
            ScenarioChoice(id: "statue", title: "Statue Waiter",
                           detail: "Looks like a waiter. Stands very still.",
                           isCorrect: false,
                           message: "The Statue was told to serve... and stood there. The soup is cold and the customers are crying. A replacement that can't do the original job breaks everything."),
            ScenarioChoice(id: "trainee", title: "Trainee Waiter",
                           detail: "Slow and shaky, but does serve.",
                           isCorrect: true,
                           message: "The Trainee spills a little soup, but every plate arrives. A good replacement does everything the original did.")
        ],
        principle: "This is Liskov Substitution (L): a replacement must work anywhere the original works.",
        examples: [
            CodeExample(
                title: "Wrong: a replacement that breaks the job",
                code: """
                class Waiter { func serve() { } }

                class StatueWaiter: Waiter {
                    override func serve() {
                        fatalError("I'm a statue!")
                    }
                }
                """,
                translation: "The restaurant expects any Waiter to serve. StatueWaiter is called a Waiter but crashes instead, so it can't be swapped in."
            ),
            CodeExample(
                title: "Correct: a replacement that still does the job",
                code: """
                class TraineeWaiter: Waiter {
                    override func serve() {
                        // serves, just slowly
                    }
                }
                """,
                translation: "A TraineeWaiter can be used anywhere a Waiter is expected and nothing breaks."
            )
        ]
    )

    // I: don't force people to promise jobs they never do.
    static let interfaceSegregation = Scenario(
        letter: "I",
        heading: "Don't force jobs people never do",
        intro: "The new Dishwasher must sign a contract. Drag a contract onto the Dishwasher (or tap the card, then tap the Dishwasher).",
        slotName: "Dishwasher",
        slotItems: ["Only washes dishes"],
        choices: [
            ScenarioChoice(id: "giant", title: "Giant Staff contract",
                           detail: "Must: cook, serve, clean AND drive the van",
                           isCorrect: false,
                           message: "The Dishwasher had to promise to cook, serve and drive the van. He wrote \"I refuse\" three times. Forcing promises nobody keeps creates silly empty code."),
            ScenarioChoice(id: "small", title: "Cleaner contract",
                           detail: "Must: clean",
                           isCorrect: true,
                           message: "The Dishwasher promises to clean. Nothing else. He signs in two seconds and nobody writes \"I refuse\".")
        ].reversed(),
        principle: "This is Interface Segregation (I): use small contracts so nobody promises things they never do.",
        examples: [
            CodeExample(
                title: "Wrong: one giant contract",
                code: """
                protocol Staff {
                    func cook()
                    func serve()
                    func clean()
                }

                class Dishwasher: Staff {
                    func cook() { }   // never does this
                    func serve() { }  // never does this
                    func clean() { /* washes */ }
                }
                """,
                translation: "Dishwasher is forced to write cook() and serve() even though he never does them. That is empty, confusing code."
            ),
            CodeExample(
                title: "Correct: small contracts",
                code: """
                protocol Cleaner { func clean() }

                class Dishwasher: Cleaner {
                    func clean() { /* washes */ }
                }
                """,
                translation: "Dishwasher only signs the contract he actually needs."
            )
        ]
    )

    // D: depend on the role (protocol), not on one specific thing.
    static let dependencyInversion = Scenario(
        letter: "D",
        heading: "Depend on a role, not one thing",
        intro: "A customer wants to pay by card. Drag a cashier onto the till (or tap the card, then tap the till).",
        slotName: "The till",
        slotItems: ["Customer pays by card"],
        choices: [
            ScenarioChoice(id: "cashOnly", title: "Cash-only Cashier",
                           detail: "Built around one cash box",
                           isCorrect: false,
                           message: "The Cashier is glued to the cash box. The customer waves a card and he asks \"What is this magic plastic?\" To take cards you'd have to rebuild him."),
            ScenarioChoice(id: "anyPayment", title: "Any-payment Cashier",
                           detail: "Takes anything that can pay",
                           isCorrect: true,
                           message: "This Cashier only asks \"can you pay?\". Cash, card or phone all work, and the Cashier never has to change.")
        ],
        principle: "This is Dependency Inversion (D): depend on the role (a protocol), not on one specific thing.",
        examples: [
            CodeExample(
                title: "Wrong: glued to one specific thing",
                code: """
                class Cashier {
                    let cash = CashBox()   // only cash, forever
                    func checkout() { cash.pay() }
                }
                """,
                translation: "Cashier only works with CashBox. To accept cards, you must open and edit Cashier."
            ),
            CodeExample(
                title: "Correct: depends on a role",
                code: """
                protocol PaymentMethod { func pay() }

                class CashBox: PaymentMethod { func pay() { } }
                class Card: PaymentMethod { func pay() { } }

                class Cashier {
                    let payment: PaymentMethod
                    func checkout() { payment.pay() }
                }
                """,
                translation: "PaymentMethod is the role. Cashier only cares that something can pay, so new ways to pay never touch Cashier."
            )
        ]
    )
}
