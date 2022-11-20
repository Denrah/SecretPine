//
//  ContentView.swift
//  SecretPine
//
//  Created by National Team on 16.11.2022.
//

import SwiftUI
import Combine
import MultipeerConnectivity

class ContentViewModel: ObservableObject {
  @Published private(set) var state: MCSessionState? = nil
  
  let mcService = MCService.shared
  
  @Published var isHost = false
  @Published var notSelectedRole = true
  
  private var subscriptions = Set<AnyCancellable>()
  
  init() {
    mcService.$state.receive(on: DispatchQueue.main).sink { [weak self] newState in
      self?.state = newState
    }.store(in: &subscriptions)
  }
  
  func start() {
    if isHost {
      mcService.displayName = Constants.hostName
    }
    mcService.isHost = isHost
    mcService.start()
  }
}

struct ContentView: View {
  @ObservedObject private var viewModel = ContentViewModel()
  
  var body: some View {
    if viewModel.notSelectedRole {
      ZStack {
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
        }
      }.background(Color(uiColor: UIColor(red: 0.042, green: 0.19, blue: 0.237, alpha: 1)).ignoresSafeArea())
        .confirmationDialog("Выберите роль", isPresented: $viewModel.notSelectedRole) {
        Button("Сосна (хост)") {
          viewModel.isHost = true
          viewModel.notSelectedRole = false
        }
        Button("Любитель природы (пользователь)") {
          viewModel.isHost = false
          viewModel.notSelectedRole = false
        }
        Button("Отмена", role: .cancel) {
          viewModel.isHost = false
          viewModel.notSelectedRole = false
        }
      }
    } else {
      Group {
        if viewModel.isHost {
          HostView()
        } else if viewModel.state == .connected {
          MessagesView()
        } else {
          PineAwaitView()
        }
      }.onAppear {
        viewModel.start()
      }
    }
  }
}
