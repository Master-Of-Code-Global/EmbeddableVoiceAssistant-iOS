//
//  ErrorRow.swift
//  VoiceAssistant
//
//  Created by Aleksandr on 08.02.2021.
//

import SwiftUI

struct ErrorRow: View, Equatable {
    var message: MessageInfo
    var body: some View {
        HStack {
            if self.message.text.count > 0 {
                HStack(spacing: 8, content: {
                    ImageView(name: "error_info")
                        .padding(EdgeInsets(top: 10, leading: 12, bottom: 10, trailing: 0))

                    Text(self.message.text)
                        .font(Font.custom("Roboto-Regular", size: 14))
                        .padding(EdgeInsets(top: 12, leading: 0, bottom: 12, trailing: 10))
                })
                .foregroundColor(.errorText)
                .background( RoundedRectangle(cornerRadius: 8)
                                .fill(Color.errorBackground))
            } else {
                EmptyView()
            }
            Spacer()
        }
        .padding(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
    }
}

struct ErrorRow_Previews: PreviewProvider {
    static var previews: some View {
        ErrorRow(message: MessageInfo(errorMessage: "Invalid token"))
    }
}
