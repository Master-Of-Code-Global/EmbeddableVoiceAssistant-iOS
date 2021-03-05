//
//  MenuButton.swift
//  VoiceAssistant
//
//  Created by Andrii Horishnii on 16.02.2021.
//

import SwiftUI

struct MenuButton: View {
    var action: () -> Void
    @Binding var isExpanded: Bool

    var body: some View {
        Button(action: action, label: {
            if isExpanded {
                ImageView(name: "menu_close")
            } else {
                ImageView(name: "menu")
            }
        })
        .frame(width: 44, height: 44)
    }
}

struct MenuButton_Previews: PreviewProvider {
    static var previews: some View {
        MenuButton(action: {}, isExpanded: .constant(false))
            .background(Color.yellow.opacity(0.1))
    }
}
