//
//  DateScroll.swift
//  Calendar
//
//  Created by Rhyse Summers on 10/06/2025.
//

import SwiftUI

struct DateScroll: View {
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 20) {
                ForEach(0..<20, id: \.self) { index in
                    Circle()
                        .fill(Color.purple)
                        .frame(width: 80, height: 80)
                        .overlay(
                            Text("\(index + 1)")
                                .foregroundColor(.white)
                                .font(.headline)
                        )
                }
            }
            .padding(.horizontal)
        }
    }
}


#Preview {
    DateScroll()
}
