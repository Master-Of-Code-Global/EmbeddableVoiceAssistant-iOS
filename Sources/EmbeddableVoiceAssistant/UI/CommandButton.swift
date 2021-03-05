//
//  CommandButton.swift
//  VoiceAssistant
//
//  Created by Aleksandr on 21.01.2021.
//

import SwiftUI

struct CommandButton: View {
    var action: () -> Void
    var text: String

    var body: some View {

        Button(action: action) {
            Text(verbatim: text)
                .padding(EdgeInsets(top: 9, leading: 16, bottom: 9, trailing: 16))
                .font(Font.custom("Roboto-Regular", size: 14))
                .foregroundColor(.commandText)
        }
        .clipShape(Capsule())
        .overlay(Capsule().strokeBorder(Color.commandText, lineWidth: 1))
    }
}

struct CommandButton_Previews: PreviewProvider {
    static var previews: some View {
        CommandButton(action: {},
                      text: "Tell me a joke")
            .frame(height: 32, alignment: .leading)
    }
}
