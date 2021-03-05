//
//  WaitingCircle.swift
//  VoiceAssistant
//
//  Created by Aleksandr on 16.02.2021.
//

import SwiftUI

struct GradientCircle: View {
    var body: some View {
        Circle()
            .fill(LinearGradient(gradient: Gradient(colors: [.recognizeBackgroundStartGradient,
                                                             .recognizeBackgroundEndGradient]),
                                 startPoint: .top,
                                 endPoint: .bottom))
            .frame(width: 8, height: 8)
    }
}

struct WaitingCircle: View {
    let index: Int
    let number: Int
    let pct: Double

    var body: some View {
        GradientCircle()
            .modifier(WaitingCircleModifier(index: index, number: number, pct: pct))
    }
}

struct WaitingCircleModifier: AnimatableModifier {
    let index: Int
    let number: Int
    var pct: Double

    var animatableData: Double {
        get { pct }
        set { pct = newValue }
    }

    func body(content: Content) -> some View {
        GradientCircle()
            .offset(x: 0, y: calcYOffset(index: index, number: number, pct: pct))
    }

    func calcYOffset(index: Int, number: Int, pct: Double) -> CGFloat {
        let halfPeriod = Double(2) / Double(4 + number - 1)
        let normalizedValue = min(max((pct - halfPeriod * Double(index) / 2), 0), (halfPeriod * 2))
        let coefficient = (normalizedValue <= halfPeriod) ? normalizedValue : (2 * halfPeriod - normalizedValue)
        return -CGFloat(coefficient*12)
    }
}

struct WaitingCircle_Previews: PreviewProvider {
    static var previews: some View {
        WaitingCircle(index: 0, number: 1, pct: 0.0)
    }
}
