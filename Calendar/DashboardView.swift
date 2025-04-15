//
//  DashboardView.swift
//  Created by GaliSrikanth on 14/04/25.

import SwiftUI

let rowFormatter: DateFormatter = {
    let f = DateFormatter()
    f.dateFormat = "yyyy-MM-dd"
    return f
}()

struct DashboardView: View {
    @State var displayedMonth: Date = Date()
    @State var selectedDate: Date? = nil
    
    let calendar: Calendar = {
        var cal = Calendar.current
        cal.locale = Locale(identifier: "en_IN")
        return cal
    }()
    
    let formatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "MMMM yyyy"
        return f
    }()
    
    var weekdays: [String] {
        let symbols = calendar.shortStandaloneWeekdaySymbols
        return Array(symbols[0...6])
    }
    
    var todayWeekdayIndex: Int {
        let originalIndex = calendar.component(.weekday, from: Date()) - 1
        return originalIndex
    }
    
    let tasks: [Task] = [
        Task(date: rowFormatter.date(from: "2025-04-01")!, title: "Team meeting"),
        Task(date: rowFormatter.date(from: "2025-04-01")!, title: "Team meeting"),
        Task(date: rowFormatter.date(from: "2025-05-04")!, title: "Team meeting"),
        Task(date: rowFormatter.date(from: "2025-04-08")!, title: "Team meeting")
    ]
    
    var body: some View {
        VStack(spacing: 24) {
            headerView
            weekView
            mainView
            meetingsListView
            
            Spacer()
        }
        .padding(.horizontal)
    }
    
    private var headerView: some View {
        HStack {
            Button {
                changeMonth(by: -1)
            } label: {
                Image(systemName: "chevron.left")
            }
            
            Spacer()
            
            Text(formatter.string(from: displayedMonth))
                .font(.headline)
            
            Spacer()
            
            Button {
                changeMonth(by: 1)
            } label: {
                Image(systemName: "chevron.right")
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
                let backgroundColor: Color = isToday ? .gray.opacity(0.4) : .gray.opacity(0.2)
                
                Text(weekdays[index])
                    .font(.system(size: 15))
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(textColor)
                    .padding(.vertical, 3)
                    .background(backgroundColor, in: RoundedRectangle(cornerRadius: 8))
            }
        }
    }
    
    @ViewBuilder
    private var mainView: some View {
        let days = generateMonthGrid()
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 2), count: 7), spacing: 2) {
            ForEach(days, id: \.self) { date in
                let isCurrentmonth = calendar.isDate(date, equalTo: displayedMonth, toGranularity: .month)
                let tasksForDay = tasks.filter{calendar.isDate($0.date, inSameDayAs: date)}
                let isSelected = selectedDate != nil && calendar.isDate(selectedDate!, inSameDayAs: date)
                
                VStack(spacing: 4) {
                    Text("\(calendar.component(.day, from: date))")
                        .font(.system(size: 15))
                        .frame(maxWidth: .infinity, minHeight: 45)
                    
                        .foregroundStyle(isSelected ? Color.se : (isCurrentmonth ? .primary : .gray))
                        .background(isSelected ? Color.primary : (isCurrentmonth ? Color.BG : Color.gray.opacity(0.2)))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .overlay {
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(lineWidth: 1)
                                .foregroundStyle(Calendar.current.isDateInToday(date) ? Color.primary : Color.clear)
                                .padding(1)
                        }
                        .overlay(alignment: .bottom) {
                            HStack(spacing: 3) {
                                ForEach(0..<min(tasksForDay.count, 5), id: \.self) { _ in
                                    Circle()
                                        .frame(width: 4, height: 4)
                                        .padding(.bottom, 6)
                                        .foregroundStyle(isSelected ? Color.se : Color.primary)
                                }
                            }
                        }
                }
                .onTapGesture {
                    if let selected = selectedDate, calendar.isDate(selected, inSameDayAs: date) {
                        selectedDate = nil
                    } else {
                        selectedDate = date
                    }
                }
            }
        }
    }
    
    private var meetingsListView: some View {
        VStack(alignment: .leading, spacing: 8) {
            let visibleTasks = (selectedDate != nil) ? (tasks.filter { calendar.isDate($0.date, inSameDayAs: selectedDate!) }) : tasks
            if visibleTasks.isEmpty {
                Text("No tasks for the day.")
                    .foregroundStyle(Color.gray)
            } else {
                ForEach(visibleTasks) { task in
                    HStack {
                        Text(task.title)
                            .frame(height: 55)
                        Spacer()
                        Image(systemName: "circle")
                    }
                    .padding(.horizontal, 12)
                    .background(Color.BG, in: RoundedRectangle(cornerRadius: 12))
                }
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
              let lastWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.end - 1) else {
            return []
        }
        
        return stride(from: firstWeek.start,
                      through: lastWeek.end,
                      by: 86400).map{ $0 }
    }
}
