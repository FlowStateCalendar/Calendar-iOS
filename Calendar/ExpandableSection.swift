//
//  ExpandableSection.swift
//  Calendar
//
//  Created by Rhyse Summers on 07/06/2025.
//

import SwiftUI

struct ExpandableSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content
    
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Title row
            HStack {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .onTapGesture {
                withAnimation {
                    isExpanded.toggle()
                }
            }

            // Expandable content
            if isExpanded {
                content()
                    .padding()
                    .transition(.opacity)
                    .background(Color(.systemBackground))
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
        .padding(.horizontal)
        .padding(.vertical, 4)
    }
}
