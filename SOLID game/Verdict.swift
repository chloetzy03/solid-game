//
//  Verdict.swift
//  SOLID game
//

import SwiftUI

// The result shown after the player checks their answer.
struct Verdict {
    let isCorrect: Bool
    let message: String
}

// Big green "CORRECT" or red "WRONG" box with a short funny line.
struct VerdictBox: View {
    let verdict: Verdict

    var body: some View {
        VStack(spacing: 6) {
            Text(verdict.isCorrect ? "✅ CORRECT!" : "❌ WRONG!")
                .font(.title.bold())
            Text(verdict.message)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(14)
        .background(verdict.isCorrect ? Color.green.opacity(0.25) : Color.red.opacity(0.2))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// Code example with a plain-English translation underneath.
struct CodeCard: View {
    let title: String
    let code: String
    let translation: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.headline)
            Text(code)
                .font(.system(.footnote, design: .monospaced))
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.black.opacity(0.85))
                .foregroundStyle(.green)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            Text("In plain English: \(translation)").font(.subheadline)
        }
        .padding(12)
        .background(.white.opacity(0.85))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}
