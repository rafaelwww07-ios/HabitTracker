//
//  FilterChip.swift
//  HabitTracker
//
//  Компонент фильтра-чипа
//

import SwiftUI

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.blue : Color(.systemGray5))
                )
        }
    }
}

#Preview {
    HStack {
        FilterChip(title: "Все", isSelected: true) {}
        FilterChip(title: "Выполненные", isSelected: false) {}
    }
    .padding()
}




