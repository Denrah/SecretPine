//
//  PineAwaitView.swift
//  SecretPine
//
//  Created by National Team on 16.11.2022.
//

import SwiftUI

struct PineAwaitView: View {
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
        Text("Сосна не обнаружена")
          .foregroundColor(.white)
          .font(.system(size: 24, weight: .bold, design: .rounded))
        Text("Попробуйте подойти поближе")
          .foregroundColor(.white)
          .font(.system(size: 16, weight: .regular, design: .rounded))
      }
    }.background(Color(uiColor: UIColor(red: 0.042, green: 0.19, blue: 0.237, alpha: 1)).ignoresSafeArea())
  }
}
