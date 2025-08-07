//
//  HeatMapView.swift
//  examples
//
//  Created by wangqiyang on 2025/8/7.
//

import SwiftUI

struct DayActivity: Identifiable {
    let id = UUID()
    let date: Date
    let count: Int
}

struct HeatMapDemoView: View {
    var body: some View {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        let existing: [DayActivity] = (0..<7).compactMap {
            guard
                let date = calendar.date(byAdding: .day, value: -6 + $0, to: today)
            else { return nil }
            return DayActivity(date: date, count: Int.random(in: 5...20))
        }

        let fullData = generateHeatmapData(existingData: existing, columns: 7, rows: 7)
        HeatMapView(data: fullData, columns: 7, rows: 7)
    }
}

struct HeatMapView: View {
    let data: [DayActivity]
    let columns: Int
    let rows: Int

    private func color(for count: Int) -> Color {
        switch count {
        case 0: return Color.gray.opacity(0.1)
        case 1...10: return Color.green.opacity(0.3)
        case 11...20: return Color.green.opacity(0.5)
        case 21...30: return Color.green.opacity(0.7)
        default: return Color.green
        }
    }

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<columns, id: \.self) { column in
                VStack(spacing: 4) {
                    ForEach(0..<rows, id: \.self) { row in
                        let index = column * rows + row
                        if index < data.count {
                            let day = data[index]
                            Rectangle()
                                .fill(color(for: day.count))
                                .frame(width: 16, height: 16)
                                .cornerRadius(2)
                        }
                    }
                }
            }
        }
        .clipShape(.rect(cornerRadius: 12))
    }
}

func generateHeatmapData(existingData: [DayActivity], columns: Int, rows: Int) -> [DayActivity] {
    guard let firstDate = existingData.first?.date,
        let lastDate = existingData.last?.date
    else {
        return []
    }

    let calendar = Calendar.current
    let today = calendar.startOfDay(for: lastDate)

    // 当前周的起点（根据系统设置的 firstWeekday）
    guard
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: today)?
            .start,
        let endOfWeek = calendar.dateInterval(of: .weekOfYear, for: today)?.end
    else {
        return []
    }

    // 开始日期：往前数 6 周（42 天）
    guard
        let desiredStartDate = calendar.date(
            byAdding: .day,
            value: -42,
            to: startOfWeek
        )
    else {
        return []
    }

    let total = columns * rows

    var result: [DayActivity] = []

    // 👉 补前面的占位（直到 existingData.first 之前）
    var current = desiredStartDate
    while current < firstDate {
        result.append(DayActivity(date: current, count: 0))
        current = calendar.date(byAdding: .day, value: 1, to: current)!
    }

    // 👉 添加已有数据
    result.append(contentsOf: existingData)

    // 👉 补后面的占位（直到本周结束，但最多总共 total 个）
    current = calendar.date(byAdding: .day, value: 1, to: lastDate)!
    while result.count < total && current < endOfWeek {
        result.append(DayActivity(date: current, count: 0))
        current = calendar.date(byAdding: .day, value: 1, to: current)!
    }

    // 👉 若仍不足 total 个，再补（跨下周，但不推荐这样）
    while result.count < total {
        result.append(DayActivity(date: current, count: 0))
        current = calendar.date(byAdding: .day, value: 1, to: current)!
    }

    // 👉 若多于 total，裁剪尾部
    if result.count > total {
        result = Array(result.suffix(total))
    }

    return result
}

#Preview {
    let calendar = Calendar.current
    let today = calendar.startOfDay(for: Date())

    let existing: [DayActivity] = (0..<7).compactMap {
        guard
            let date = calendar.date(byAdding: .day, value: -6 + $0, to: today)
        else { return nil }
        return DayActivity(date: date, count: Int.random(in: 5...20))
    }

    let fullData = generateHeatmapData(existingData: existing, columns: 7, rows: 7)
    HeatMapView(data: fullData, columns: 8, rows: 7)
}
