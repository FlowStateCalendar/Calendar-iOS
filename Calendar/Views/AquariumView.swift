//
//  AquriumView.swift
//  Calendar
//
//  Created by Rhyse Summers on 07/06/2025.
//

import SwiftUI

struct AquariumView: View {
    var body: some View {
        VStack{
            UserBar()
            Text("Welcome to your aquarium")
            Spacer()
            Text("Coming Soon!")
            Spacer()
        }
        .background(Color(.teal))
    }
}


#Preview {
    AquariumView()
}
