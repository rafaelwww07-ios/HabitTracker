//
//  TemplatesView.swift
//  HabitTracker
//
//  Экран с шаблонами привычек
//

import SwiftUI

struct TemplatesView: View {
    let onSelectTemplate: (HabitTemplate) -> Void
    @Environment(\.dismiss) var dismiss
    @State private var searchText = ""
    
    var filteredTemplates: [HabitTemplate] {
        if searchText.isEmpty {
            return HabitTemplate.templates
        } else {
            return HabitTemplate.templates.filter { template in
                template.name.localizedCaseInsensitiveContains(searchText) ||
                template.description.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var groupedTemplates: [HabitCategory: [HabitTemplate]] {
        Dictionary(grouping: filteredTemplates) { $0.category }
    }
    
    var body: some View {
        NavigationView {
            List {
                SearchBarView(text: $searchText)
                    .listRowInsets(EdgeInsets())
                
                ForEach(Array(groupedTemplates.keys.sorted { $0.rawValue < $1.rawValue }), id: \.self) { category in
                    if let templates = groupedTemplates[category] {
                        Section {
                            ForEach(templates) { template in
                                TemplateRowView(template: template) {
                                    onSelectTemplate(template)
                                    dismiss()
                                }
                            }
                        } header: {
                            HStack {
                                Image(systemName: category.icon)
                                    .foregroundColor(category.color)
                                Text(category.rawValue)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Шаблоны привычек")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Готово") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct TemplateRowView: View {
    let template: HabitTemplate
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 16) {
                Image(systemName: template.iconName)
                    .font(.title2)
                    .foregroundColor(Color(hex: template.colorHex))
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(Color(hex: template.colorHex)?.opacity(0.1) ?? Color.gray.opacity(0.1))
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(template.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(template.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                Image(systemName: "plus.circle.fill")
                    .foregroundColor(.blue)
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    TemplatesView(onSelectTemplate: { _ in })
}

