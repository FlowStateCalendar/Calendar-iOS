//
//  CompletingTask.swift
//  Calendar
//
//  Created by Rhyse Summers on 10/06/2025.
//

import SwiftUI

struct CompletingTask: View {
    var body: some View {
        VStack{
            UserBar()
            Text("Current Task")
            Spacer()
            Text("Completing!...")
            Spacer()
        }
        .background(Color(.teal))
    }
}


#Preview {
    CompletingTask()
}
