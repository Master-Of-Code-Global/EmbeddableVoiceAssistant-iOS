//
//  RecognizeButton.swift
//  VoiceAssistant
//
//  Created by Aleksandr on 15.01.2021.
//

import SwiftUI

struct RecognizeButton: View {
 //   @ObservedObject private var voiceLevel = VoiceAssistant.shared.voiceLevel

    var action: () -> Void
    var isListening: Bool
    @ObservedObject var voiceLevel: Measurement

    let iconSize: CGFloat = 48

    var body: some View {
        GeometryReader { geometryProxy in
            let proxySize = geometryProxy.size.width,
                coefficient = min(max(voiceLevel.coefficient(isListening), 0), 1),
                visibleSize = iconSize + (proxySize - iconSize) * coefficient,
                offset = (proxySize - visibleSize)/2

            Button(action: action) {
                ImageView(name: (isListening) ? "active_voice" : "microphone")
                    .frame(width: iconSize, height: iconSize, alignment: .center)
            }
            .frame(width: geometryProxy.size.width,
                   height: geometryProxy.size.height,
                   alignment: .center)
            .background(Capsule()
                            .size(width: visibleSize, height: visibleSize)
                            .offset(x: offset, y: offset)
                            .fill(Color.soundLevel))
            .animation(Animation.easeOut)
        }
    }
}

struct RecognizeButton_Previews: PreviewProvider {
    static var previews: some View {
        RecognizeButton(action: {},
                        isListening: true,
                        voiceLevel: Measurement())
            .frame(width: 76, height: 76, alignment: .center)
    }
}
