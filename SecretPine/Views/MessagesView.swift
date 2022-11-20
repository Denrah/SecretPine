//
//  MessagesView.swift
//  SecretPine
//
//  Created by National Team on 16.11.2022.
//

import SwiftUI

struct Message: Codable {
  let name: String
  let text: String
}

class MessagesViewModel: ObservableObject {
  @Published var messages: [Message] = []
  
  private let mcService = MCService.shared
  
  init() {
    mcService.onDidReceivedEvent = { [weak self] event in
      if case .messages(let messages) = event {
        DispatchQueue.main.async {
          self?.messages = messages
        }
      }
    }
  }
  
  func send(name: String, text: String) {
    mcService.send(event: .message(message: Message(name: name, text: text)))
  }
}

struct MessagesView: View {
  @ObservedObject private var viewModel = MessagesViewModel()
  
  @State var isEditorPresented = false
  @State var nameText = ""
  @State var messageText = ""
  
  init() {
    UITextView.appearance().backgroundColor = .clear
  }
  
  var body: some View {
    ZStack {
      VStack {
        Spacer()
        Image("trees")
          .resizable()
          .renderingMode(.template)
          .aspectRatio(contentMode: .fit)
          .foregroundColor(Color(uiColor: UIColor(red: 0.065, green: 0.345, blue: 0.363, alpha: 1)))
      }.ignoresSafeArea()
      ScrollView(.vertical, showsIndicators: false) {
        LazyVStack {
          HStack {
            Text("Сообщения")
              .foregroundColor(.white)
              .font(.system(size: 24, weight: .bold, design: .rounded))
            Spacer()
          }
          ForEach(viewModel.messages.indices, id: \.self) { index in
            VStack(alignment: .leading, spacing: 8) {
              HStack {
                Text(viewModel.messages[index].name)
                  .foregroundColor(.white)
                  .font(.system(size: 14, weight: .bold, design: .rounded))
                  .opacity(0.8)
                Spacer()
              }
              Text(viewModel.messages[index].text)
                .foregroundColor(.white)
                .font(.system(size: 16, weight: .regular, design: .rounded))
            }.padding(16)
              .background(Color.black.opacity(0.6))
              .cornerRadius(8)
              .padding(.bottom, 8)
          }
        }.padding(16).padding(.bottom, 88)
      }.sheet(isPresented: $isEditorPresented) {
        VStack {
          HStack {
            Text("Имя")
              .foregroundColor(.white)
              .font(.system(size: 24, weight: .bold, design: .rounded))
            Spacer()
          }.padding(.horizontal, 16).padding(.top, 16)
          TextField("Имя", text: $nameText)
            .foregroundColor(.white)
            .frame(height: 40)
            .background(Color(uiColor: UIColor(red: 0.065, green: 0.345, blue: 0.363, alpha: 1)))
            .cornerRadius(8)
            .padding(.horizontal, 16)
          HStack {
            Text("Сообщение")
              .foregroundColor(.white)
              .font(.system(size: 24, weight: .bold, design: .rounded))
            Spacer()
          }.padding(.horizontal, 16).padding(.top, 16)
          ZStack {
            Color(uiColor: UIColor(red: 0.065, green: 0.345, blue: 0.363, alpha: 1))
            if #available(iOS 16.0, *) {
              TextEditor(text: $messageText)
                .scrollContentBackground(.hidden)
                .foregroundColor(.white)
            } else {
              TextEditor(text: $messageText)
                .foregroundColor(.white)
            }
          }.cornerRadius(8)
            .padding(16).padding(.top, 0)
          HStack {
            Button {
              viewModel.send(name: nameText, text: messageText)
              isEditorPresented = false
              messageText = ""
              nameText = ""
            } label: {
              Spacer()
              Text("Отправить")
                .foregroundColor(.white)
                .font(.system(size: 16, weight: .bold, design: .rounded))
              Spacer()
            }.frame(height: 48)
              .background(Color(uiColor: UIColor(red: 0.203, green: 0.65, blue: 0.675, alpha: 1)))
              .cornerRadius(8)
              .disabled(messageText.isEmpty || nameText.isEmpty)
          }.padding(16)
        }.background(Color(uiColor: UIColor(red: 0.042, green: 0.19, blue: 0.237, alpha: 1)).ignoresSafeArea())
      }
      VStack {
        Spacer()
        Button {
          isEditorPresented = true
        } label: {
          Spacer()
          Text("Написать")
            .foregroundColor(.white)
            .font(.system(size: 16, weight: .bold, design: .rounded))
          Spacer()
        }.frame(height: 48)
          .background(Color(uiColor: UIColor(red: 0.203, green: 0.65, blue: 0.675, alpha: 1)))
          .cornerRadius(8)
        
      }.padding(16)
    }.background(Color(uiColor: UIColor(red: 0.042, green: 0.19, blue: 0.237, alpha: 1)).ignoresSafeArea())
  }
}
