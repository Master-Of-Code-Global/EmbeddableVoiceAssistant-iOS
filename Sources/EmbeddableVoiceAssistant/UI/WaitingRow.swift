//
//  WaitingRow.swift
//  VoiceAssistant
//
//  Created by Aleksandr on 16.02.2021.
//

import SwiftUI

struct WaitingRow: View {
    @State private var flag = false
    let circleNumber = 3

    var body: some View {
        HStack(alignment: .bottom, spacing: 4, content: {
            ForEach(0..<circleNumber) { index in
                WaitingCircle(index: index, number: circleNumber, pct: flag ? 1.0 : 0.0)
            }
            Spacer()
        })
        .padding(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
        .onAppear {
            withAnimation(Animation.linear(duration: 1).delay(1).repeatForever(autoreverses: false)) {
                self.flag.toggle()
            }
        }
    }
}

struct WaitingRow_Previews: PreviewProvider {
    static var previews: some View {
        WaitingRow()
    }
}
