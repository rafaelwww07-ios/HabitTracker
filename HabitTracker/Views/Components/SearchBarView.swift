//
//  SearchBarView.swift
//  HabitTracker
//
//  Компонент поиска
//

import SwiftUI

struct SearchBarView: View {
    @Binding var text: String
    var placeholder: String = "Поиск..."
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField(placeholder, text: $text)
                .textFieldStyle(PlainTextFieldStyle())
            
            if !text.isEmpty {
                Button(action: {
                    text = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.systemGray6))
        )
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var searchText = ""
        var body: some View {
            SearchBarView(text: $searchText)
                .padding()
        }
    }
    return PreviewWrapper()
}

