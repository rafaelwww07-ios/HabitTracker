//
//  ProgressChartView.swift
//  HabitTracker
//
//  График прогресса с использованием SwiftUI Charts
//

import SwiftUI
import Charts

struct ProgressChartView: View {
    let data: [Double]
    let habitColor: Color
    
    var body: some View {
        Chart {
            ForEach(Array(data.enumerated()), id: \.offset) { index, value in
                BarMark(
                    x: .value("Неделя", index + 1),
                    y: .value("Процент", value)
                )
                .foregroundStyle(habitColor.gradient)
                .cornerRadius(4)
            }
        }
        .frame(height: 200)
        .chartYAxis {
            AxisMarks(position: .leading, values: [0, 25, 50, 75, 100]) { value in
                AxisGridLine()
                AxisValueLabel {
                    if let intValue = value.as(Int.self) {
                        Text("\(intValue)%")
                            .font(.caption2)
                            .foregroundStyle(Color.secondary)
                    }
                }
            }
        }
        .chartXAxis {
            AxisMarks { _ in
                AxisValueLabel()
                    .font(.caption2)
            }
        }
    }
}

#Preview {
    ProgressChartView(
        data: [60, 80, 45, 90, 100, 75, 85, 95, 70, 80, 90, 100],
        habitColor: .blue
    )
    .padding()
}

