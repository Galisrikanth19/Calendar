//
//  DashboardView.swift
//  Created by GaliSrikanth on 14/04/25.

import SwiftUI

struct DashboardView: View {
    @State var displayedMonth: Date = Date()
    @State var selectedDate: Date? = nil
    
    let calendar = Calendar.current
    let formatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "MMMM yyyy"
        return f
    }()
    
    var weekdays: [String] {
        let symbols = calendar.shortStandaloneWeekdaySymbols
        return symbols //Array(symbols[0...6])
    }
    
    var todayWeekdayIndex: Int {
        let originalIndex = calendar.component(.weekday, from: Date())
        return originalIndex//(originalIndex + 6) % 7
    }
    
    var body: some View {
        VStack(spacing: 24) {
            headerView
            weekView
            
            let days = generateMonthGrid()
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 2), count: 7), spacing: 2) {
                ForEach(days, id: \.self) { date in
                    let isCurrentmonth = calendar.isDate(date, equalTo: displayedMonth, toGranularity: .month)
                    let isSelected = selectedDate != nil && calendar.isDate(selectedDate!, inSameDayAs: date)
                    
                    VStack(spacing: 4) {
                        Text("\(calendar.component(.day, from: date))")
                            .font(.system(size: 15))
                            .frame(maxWidth: .infinity, minHeight: 45)
                        
                            .foregroundStyle(isSelected ? .red : (isCurrentmonth ? .primary : .gray))
                            .background(isSelected ? Color.primary : (isCurrentmonth ? Color.yellow : Color.gray.opacity(0.2)))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .overlay {
                                RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.blue, lineWidth: 2)
                                            .padding(1)
                            }
                    }
                }
            }
        }
        .padding(.horizontal)
    }
    
    private var headerView: some View {
        HStack {
            Button {
                changeMonth(by: -1)
            } label: {
                Image(systemName: "chevron.left")
                    .imageScale(.large)
            }
            
            Spacer()
            
            Text(formatter.string(from: displayedMonth))
                .font(.headline)
            
            Spacer()
            
            Button {
                changeMonth(by: 1)
            } label: {
                Image(systemName: "chevron.right")
                    .imageScale(.large)
            }
        }
        .tint(.primary)
        .padding(.horizontal)
    }
    
    private var weekView: some View {
        HStack(spacing: 2) {
            ForEach(weekdays.indices, id: \.self) { index in
                let isToday = index == todayWeekdayIndex
                let textColor: Color = isToday ? .primary : .gray
                let backgroundColor: Color = isToday ? .red.opacity(0.4) : .gray.opacity(0.2)

                Text(weekdays[index])
                    .font(.system(size: 15))
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(textColor)
                    .padding(.vertical, 3)
                    .background(backgroundColor, in: RoundedRectangle(cornerRadius: 8))
            }
        }
    }
}

extension DashboardView {
    private func changeMonth(by value: Int) {
        displayedMonth = calendar.date(byAdding: .month,
                                       value: value,
                                       to: displayedMonth) ?? displayedMonth
    }
    
    private func generateMonthGrid() -> [Date] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: displayedMonth),
              let firstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start),
              let lastWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.end + 10) else {
            return []
        }
        
        var result = stride(from: firstWeek.start,
                      through: lastWeek.end,
                      by: 86400).map{$0}
        return result.dropLast(2)
    }
}
