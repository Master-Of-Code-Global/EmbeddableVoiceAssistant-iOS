//
//  KeyboardBar.swift
//  VoiceAssistant
//
//  Created by Aleksandr on 22.01.2021.
//

import SwiftUI
import Introspect

struct KeyboardBar: View {
    var menuAction: () -> Void
    var sendAction: (_ text: String) -> Void
    var recognizeModeAction: () -> Void
    @Binding var isMenuExpanded: Bool
    @State private var text: String = ""

    var body: some View {
        VStack(spacing: 0, content: {
            Rectangle()
                .fill(Color.delimiter)
                .frame(height: 1)

            HStack(spacing: 4, content: {
                MenuButton(action: menuAction, isExpanded: $isMenuExpanded)
                    .padding(.leading, 10)
                HStack(spacing: 0, content: {
                    TextField("",
                              text: $text) { (_) in
                    } onCommit: {
                        self.sendAction(self.text)
                    }
                    .font(Font.custom("Roboto-Regular", size: 14))
                    .padding(.leading, 15)

                    Button(action: {
                        self.sendAction(self.text.trimmingCharacters(in: .whitespacesAndNewlines))
                    },
                    label: {
                        ImageView(name: self.text.isEmptyAfterTrim() ? "send_disabled" : "send")
                    })
                    .frame(width: 36, height: 40)
                    .disabled(self.text.isEmptyAfterTrim())
                })
                .frame(height: 32)
                .clipShape(Capsule())
                .overlay(Capsule().strokeBorder(Color.delimiter, lineWidth: 1))
                .introspectTextField { textField in
                    textField.becomeFirstResponder()
                }

                Button(action: recognizeModeAction, label: {
                    ImageView(name: "microphone_small")
                })
                .frame(width: 44, height: 44)
                .padding(.trailing, 10)
            })
            .frame(height: 51)
        })
    }
}

struct KeyboardBar_Previews: PreviewProvider {
    static var previews: some View {
        KeyboardBar(menuAction: {},
                    sendAction: {_ in },
                    recognizeModeAction: {},
                    isMenuExpanded: .constant(false))
            .background(Color.yellow.opacity(0.1))
    }
}

extension String {
    func isEmptyAfterTrim() -> Bool {
        self.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
