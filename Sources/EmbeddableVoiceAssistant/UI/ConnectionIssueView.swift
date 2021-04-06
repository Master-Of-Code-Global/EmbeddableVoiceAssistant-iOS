//
//  ConnectionIssueView.swift
//  
//
//  Created by Aleksandr on 29.03.2021.
//

import SwiftUI

struct ConnectionIssueView: View {
    let errorDescription: String?

    var body: some View {
        if let errorDescription = errorDescription{
            HStack(spacing: 8, content: {
                Spacer()

                ImageView(name: "error_info")
                    .padding(EdgeInsets(top: 10, leading: 12, bottom: 10, trailing: 0))

                Text(errorDescription)
                    .font(Font.custom("Roboto-Regular", size: 14))
                    .padding(EdgeInsets(top: 12, leading: 0, bottom: 12, trailing: 10))

                Spacer()
            })
            .foregroundColor(.errorText)
            .background(Color.errorBackground)
        } else {
            EmptyView()
        }
    }
}

struct ConnectionIssueView_Previews: PreviewProvider {
    static var previews: some View {
        ConnectionIssueView(errorDescription: "No Internet connection") 
    }
}
