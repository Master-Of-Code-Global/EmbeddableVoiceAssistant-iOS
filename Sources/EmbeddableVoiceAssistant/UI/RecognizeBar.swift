//
//  RecognizeBar.swift
//  VoiceAssistant
//
//  Created by Aleksandr on 22.01.2021.
//

import SwiftUI

struct RecognizeBar: View {
    var recognizeAction: () -> Void
    var menuAction: () -> Void
    var keyboardModeAction: () -> Void
    var isListening: Bool
    @Binding var isMenuExpanded: Bool
    var voiceLevel: Measurement

    var body: some View {
        ZStack {
            RecognizeButton(action: recognizeAction,
                            isListening: isListening,
                            voiceLevel: voiceLevel)
                .frame(width: 72, height: 72)
                .offset(y: -7)
                .zIndex(1)

            Rectangle()
                .fill(Color.delimiter)
                .frame(height: 1)
                .offset(y: -7)

            HStack {
                MenuButton(action: menuAction, isExpanded: $isMenuExpanded)
                    .padding(.leading, 10)

                Spacer()

                Button(action: keyboardModeAction, label: {
                    ImageView(name: "keyboard")
                })
                .frame(width: 44, height: 44)
                .padding(.trailing, 10)
            }
            .frame(height: 44)
            .offset(y: 19)
        }
        .frame(height: 86)
    }
}

struct RecognizeBar_Previews: PreviewProvider {
    static var previews: some View {
        RecognizeBar(recognizeAction: {},
                     menuAction: {},
                     keyboardModeAction: {},
                     isListening: true,
                     isMenuExpanded: .constant(false),
                     voiceLevel: Measurement())
            .background(Color.yellow.opacity(0.1))
    }
}
