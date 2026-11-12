//
//  KitchenLevelView.swift
//  SOLID game
//

import SwiftUI

struct KitchenLevelView: View {
    // "StateObject" = the screen owns the brain and redraws when it changes.
    @StateObject private var level = KitchenLevel()

    var body: some View {
        ZStack {
            LinearGradient(colors: [.yellow.opacity(0.35), .orange.opacity(0.3)],
                           startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 14) {
                    Text("Game S").font(.largeTitle.bold())
                    Text("One person, one job").font(.title3.bold())

                    Text("SuperWaiter is doing EVERYTHING. Give each job to its own person: drag a job onto a chair (or tap the job, then tap the chair). Then press Check.")
                        .font(.subheadline)
                        .multilineTextAlignment(.center)

                    ForEach(level.workers) { worker in
                        workerBox(worker)
                    }

                    Button("Check my team") { level.check() }
                        .font(.title3.bold())
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(.pink)
                        .foregroundStyle(.white)
                        .clipShape(Capsule())

                    if let verdict = level.verdict {
                        VerdictBox(verdict: verdict)

                        if verdict.isCorrect {
                            explanation
                        }
                    }
                }
                .padding()
            }
        }
    }

    // One worker and the jobs they do.
    private func workerBox(_ worker: Worker) -> some View {
        VStack(spacing: 8) {
            Text(worker.name).font(.headline)

            HStack(spacing: 8) {
                if worker.jobs.isEmpty {
                    Text("drop a job here").font(.footnote).foregroundStyle(.secondary)
                }
                ForEach(worker.jobs) { job in
                    jobChip(job)
                }
            }
            .frame(minHeight: 40)
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(.white.opacity(0.85))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(level.selectedJob != nil ? Color.orange : .clear,
                        style: StrokeStyle(lineWidth: 3, dash: [6]))
        )
        // Drop a dragged job here...
        .dropDestination(for: String.self) { items, _ in
            guard let raw = items.first, let job = Job(rawValue: raw) else { return false }
            level.move(job, to: worker.id)
            return true
        }
        // ...or tap a job first, then tap this worker.
        .onTapGesture {
            if let job = level.selectedJob { level.move(job, to: worker.id) }
        }
    }

    // A job card you can drag around.
    private func jobChip(_ job: Job) -> some View {
        Text(job.title)
            .font(.subheadline.bold())
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.orange.opacity(0.25))
            .clipShape(Capsule())
            .overlay(Capsule().stroke(level.selectedJob == job ? Color.pink : .clear, lineWidth: 3))
            .draggable(job.rawValue)
            .onTapGesture { level.selectedJob = (level.selectedJob == job) ? nil : job }
    }

    // Shown only after the player gets it right.
    private var explanation: some View {
        VStack(spacing: 12) {
            Text("This is Single Responsibility (S): every class does ONE job.")
                .font(.headline)
                .multilineTextAlignment(.center)

            CodeCard(
                title: "Wrong: one class, three jobs",
                code: """
                class SuperWaiter {
                    func takeOrder() { }
                    func cookOrder() { }
                    func serveOrder() { }
                }
                """,
                translation: "To change how cooking works, you open SuperWaiter, where ordering and serving live too. One slip breaks them."
            )

            CodeCard(
                title: "Correct: one job per class",
                code: """
                class OrderTaker { func takeOrder() { } }
                class Chef       { func cookOrder() { } }
                class Waiter     { func serveOrder() { } }
                """,
                translation: "To change cooking, you open Chef only. Everything else is safe."
            )

            Button("Play again") { level.reset() }
                .buttonStyle(.bordered)
        }
    }
}

#Preview {
    KitchenLevelView()
}
