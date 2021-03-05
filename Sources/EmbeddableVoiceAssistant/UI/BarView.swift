//
//  BarView.swift
//  VoiceAssistant
//
//  Created by Aleksandr on 15.01.2021.
//

import SwiftUI
import MessageUI

struct BarView: View {
    var clearHistoryAction: () -> Void
    @State private var isExpanded = false
    @State var result: Result<MFMailComposeResult, Error>?
    @State var isShowingMailView = false

    var body: some View {
        VStack {
            HStack {
                ImageView(name: "moc_logo")
                    .padding([.top, .leading, .bottom], 10)

                Text("MOC Voice Assistant")
                    .font(Font.custom("Roboto-Regular", size: 16))

                Spacer()

                Button(action: {
                    isExpanded.toggle()
                }, label: {
                    ImageView(name: isExpanded ? "hide" : "open")
                })
                .frame(width: 44, height: 44)
            }

            if isExpanded {
                VStack {
                    Rectangle()
                        .fill(Color.delimiter)
                        .frame(height: 1)

                    Button(action: {
                        clearHistoryAction()
                        isExpanded = false
                    }, label: {
                        ImageView(name: "trash")
                        Text("Clear History")
                            .font(Font.custom("Roboto-Regular", size: 14))
                            .foregroundColor(.subtleText)
                        Spacer()
                    })
                    .frame(height: 46)

                    Rectangle()
                        .fill(Color.delimiter)
                        .frame(height: 1)

                    Button(action: {
                        self.isShowingMailView.toggle()
                    }, label: {
                        ImageView(name: "letter")
                        Text("Contact developers")
                            .font(Font.custom("Roboto-Regular", size: 14))
                            .foregroundColor(MFMailComposeViewController.canSendMail() ?
                                                .subtleText: .subtleDisabledText)
                        Spacer()
                    })
                    .frame(height: 46)
                    .disabled(!MFMailComposeViewController.canSendMail())
                    .sheet(isPresented: $isShowingMailView) {
                        MailView(isShowing: self.$isShowingMailView, result: self.$result)
                    }

                    Rectangle()
                        .fill(Color.delimiter)
                        .frame(height: 1)
                        .padding(.bottom, 16)

                }
                .padding([.leading, .trailing], 48)
            }
        }
        .background(LinearGradient(gradient: Gradient(colors: [.topBarBackgroundStartGradient, .topBarBackgroundEndGradient]),
                                   startPoint: .top,
                                   endPoint: .bottom))
        .animation(.easeInOut)
        .onChange(of: isShowingMailView, perform: { (_) in
            if let result = result {
                switch result {
                case .success(let mailComposeResult):
                    print("Send email result code: \(mailComposeResult.rawValue)")
                case .failure(let error):
                    print("Send email errore: \(error.localizedDescription)")
                }
                isExpanded = false
                self.result = nil
            }
        })
    }
}

struct BarView_Previews: PreviewProvider {
    static var previews: some View {
        BarView {}
        Spacer()
    }
}
