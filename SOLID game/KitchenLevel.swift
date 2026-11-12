//
//  KitchenLevel.swift
//  SOLID game
//

import Foundation
import Combine

// The three jobs in the restaurant.
enum Job: String, CaseIterable, Identifiable {
    case takeOrder, cook, serve

    var id: String { rawValue }

    var title: String {
        switch self {
        case .takeOrder: return "Take orders"
        case .cook: return "Cook"
        case .serve: return "Serve"
        }
    }

    // The person who ONLY does this job.
    var specialist: String {
        switch self {
        case .takeOrder: return "Order Taker"
        case .cook: return "Chef"
        case .serve: return "Waiter"
        }
    }
}

// A worker = one class in your code. "jobs" = the functions inside it.
struct Worker: Identifiable {
    let id = UUID()
    var jobs: [Job]

    var name: String {
        switch jobs.count {
        case 0: return "Empty chair"
        case 1: return jobs[0].specialist
        case 2: return "Overworked person"
        default: return "SuperWaiter"
        }
    }
}

// The "brain" of Game S: rules only, no drawing.
// Translation: the screen only DRAWS; this file only DECIDES.
@MainActor
final class KitchenLevel: ObservableObject {
    // "@Published" = the screen redraws whenever these change.
    @Published private(set) var workers: [Worker] = []
    @Published var selectedJob: Job?          // chosen by tapping (alternative to dragging)
    @Published private(set) var verdict: Verdict?

    init() { reset() }

    // Start over: ONE SuperWaiter doing everything, plus two empty chairs.
    func reset() {
        workers = [Worker(jobs: Job.allCases), Worker(jobs: []), Worker(jobs: [])]
        selectedJob = nil
        verdict = nil
    }

    // Move a job to another worker.
    func move(_ job: Job, to workerID: UUID) {
        for index in workers.indices {
            workers[index].jobs.removeAll { $0 == job }
        }
        if let target = workers.firstIndex(where: { $0.id == workerID }) {
            workers[target].jobs.append(job)
        }
        selectedJob = nil
        verdict = nil
    }

    // Correct only if nobody has more than ONE job.
    func check() {
        let busiest = workers.map(\.jobs.count).max() ?? 0

        switch busiest {
        case 1:
            verdict = Verdict(isCorrect: true,
                              message: "One person, one job. The Chef cooks, the Waiter serves, and nobody is crying in the freezer.")
        case 2:
            verdict = Verdict(isCorrect: false,
                              message: "Someone still has 2 jobs. He's cooking with one hand and taking orders with the other. Give every job its own person!")
        default:
            verdict = Verdict(isCorrect: false,
                              message: "SuperWaiter is cooking, serving AND taking orders at once. He just served a customer raw dough. Split the jobs!")
        }
    }
}
