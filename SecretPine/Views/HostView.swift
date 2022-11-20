//
//  HostView.swift
//  SecretPine
//
//  Created by National Team on 18.11.2022.
//

import SwiftUI
import Combine

class HostViewModel: ObservableObject {
  private let mcService = MCService.shared
  
  @Published private(set) var lastMessage: Message?
  
  private var subscriptions = Set<AnyCancellable>()
  
  init() {
    mcService.$messages.receive(on: DispatchQueue.main).sink { [weak self] messages in
      self?.lastMessage = messages.last
    }.store(in: &subscriptions)
  }
}

struct HostView: View {
  @ObservedObject private var viewModel = HostViewModel()
  
  var body: some View {
    ZStack {
      VStack {
        HStack {
          Spacer()
        }
        Spacer()
      }
      Image("pine")
        .resizable()
        .aspectRatio(contentMode: .fit)
        .padding(40)
      VStack {
        Text("Сосна вещает и ждёт посетителей")
          .multilineTextAlignment(.center)
          .foregroundColor(.white)
          .font(.system(size: 24, weight: .bold, design: .rounded))
        Text("Последнее сообщение:")
          .foregroundColor(.white)
          .font(.system(size: 16, weight: .regular, design: .rounded))
        VStack {
          if let message = viewModel.lastMessage {
            VStack(alignment: .leading, spacing: 8) {
              HStack {
                Text(message.name)
                  .foregroundColor(.white)
                  .font(.system(size: 14, weight: .bold, design: .rounded))
                  .opacity(0.8)
                Spacer()
              }
              Text(message.text)
                .foregroundColor(.white)
                .lineLimit(3)
                .font(.system(size: 16, weight: .regular, design: .rounded))
            }.padding(16)
              .background(Color.black.opacity(0.6))
              .cornerRadius(8)
              .padding(.bottom, 8)
          }
          Spacer()
        }.frame(height: 200)
          .padding(.horizontal, 16)
      }
    }.background(Color(uiColor: UIColor(red: 0.042, green: 0.19, blue: 0.237, alpha: 1)).ignoresSafeArea())
  }
}
