//
//  RequestRow.swift
//  VoiceAssistant
//
//  Created by Aleksandr on 29.12.2020.
//

import SwiftUI

struct RequestRow: View {
    var message: MessageInfo
    var resetMessageAction: () -> Void

    var body: some View {

        let textMessage = Text(self.message.text)
            .font(Font.custom("Roboto-Regular", size: 14))
            .padding(EdgeInsets(top: 12, leading: 10, bottom: 12, trailing: 10))
            .foregroundColor(.requestText)

        let result = HStack {
            Spacer()
            if message.type == .recognizing {
                textMessage
                    .background(RequestShape()
                                    .fill(LinearGradient(gradient: Gradient(colors: [.recognizeBackgroundStartGradient,
                                                                                     .recognizeBackgroundEndGradient]),
                                                         startPoint: .top,
                                                         endPoint: .bottom ))
                    )
                    .overlay(Button(action: resetMessageAction,
                                    label: {
                                        HStack {
                                            Spacer()
                                            VStack {
                                                ImageView(name: "reset_message")
                                                    .frame(width: 18, height: 18)
                                                Spacer()
                                            }
                                        }
                                    }).frame(maxWidth: .infinity, maxHeight: .infinity))
            } else {
                textMessage
                    .background(RequestShape()
                                    .fill(Color.requestBackground))
            }
        }
        .padding(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))

        return result
    }
}

struct RequestRow_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            RequestRow(message: MessageInfo.mockRequestData()) { }
        }
    }
}
