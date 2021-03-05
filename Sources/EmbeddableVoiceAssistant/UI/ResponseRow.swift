//
//  ResponseRow.swift
//  VoiceAssistant
//
//  Created by Aleksandr on 29.12.2020.
//

import SwiftUI

struct ResponseRow: View {
    var message: MessageInfo
    var sendMessageAction: (_ text: String) -> Void

    var body: some View {
        VStack {
            if self.message.text.count > 0 {
                HStack {
                    Text(self.message.text)
                        .font(Font.custom("Roboto-Regular", size: 14))
                        .padding(EdgeInsets(top: 12, leading: 10, bottom: 12, trailing: 10))
                        .foregroundColor(.responseText)
                        .background( ResponseShape()
                                        .fill(Color.responseBackground))
                    Spacer()
                }
                .padding(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
            } else {
                EmptyView()
            }

            if message.actionsInfo.count > 0 {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(message.actionsInfo, id: \.self) { actionInfo in
                        HStack {
                            CommandButton(action: {
                                sendMessageAction(actionInfo.displayValue())
                            }, text: actionInfo.displayValue())
                            .padding(.leading, 16)

                            Spacer()
                        }
                    }
                }
            } else {
                EmptyView()
            }
        }
    }
}

struct ResponseRow_Previews: PreviewProvider {
    static var previews: some View {
        ResponseRow(message: MessageInfo.mockResponseData()) { (_ text) in
        }
    }
}
