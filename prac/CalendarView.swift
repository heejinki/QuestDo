//
//  CalendarView.swift
//  prac
//
//  월간 캘린더 + 날짜 선택
//

import SwiftUI

struct CalendarView: View {
    @Binding var selectedDate: Date
    var todoStore: TodoStore

    @State private var displayedMonth: Date = Date()
    @State private var showYearMonthPicker: Bool = false

    private let calendar = Calendar.current
    private let weekdaySymbols = ["일", "월", "화", "수", "목", "금", "토"]
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)

    var body: some View {
        VStack(spacing: 12) {
            // 월 이동 헤더
            monthHeader
            // 요일 라벨
            weekdayHeader
            // 날짜 그리드
            dateGrid
        }
        .padding()
        .glassCard()
    }

    // MARK: - 월 헤더

    private var monthHeader: some View {
        HStack {
            Button { moveMonth(-1) } label: {
                Image(systemName: "chevron.left")
                    .fontWeight(.semibold)
            }

            Spacer()

            Button {
                showYearMonthPicker = true
            } label: {
                HStack(spacing: 4) {
                    Text(monthTitle)
                        .font(.headline)
                    Image(systemName: "chevron.down")
                        .font(.caption)
                }
                .foregroundStyle(.primary)
            }
            .sheet(isPresented: $showYearMonthPicker) {
                YearMonthPickerSheet(
                    selectedDate: $displayedMonth,
                    isPresented: $showYearMonthPicker
                )
                .presentationDetents([.medium])
            }

            Spacer()

            Button { moveMonth(1) } label: {
                Image(systemName: "chevron.right")
                    .fontWeight(.semibold)
            }
        }
    }

    // MARK: - 요일 라벨

    private var weekdayHeader: some View {
        HStack {
            ForEach(weekdaySymbols, id: \.self) { symbol in
                Text(symbol)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    // MARK: - 날짜 그리드

    private var dateGrid: some View {
        let days = makeDays()
        return LazyVGrid(columns: columns, spacing: 8) {
            ForEach(days, id: \.self) { date in
                if let date = date {
                    dayCell(date)
                } else {
                    Text("")
                        .frame(height: 40)
                }
            }
        }
    }

    // MARK: - 개별 날짜 셀

    private func dayCell(_ date: Date) -> some View {
        let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
        let isToday = calendar.isDateInToday(date)
        let hasTodos = todoStore.hasTodos(on: date)
        let completionRate = todoStore.completionRate(for: date)

        return Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedDate = date
            }
        } label: {
            VStack(spacing: 2) {
                Text("\(calendar.component(.day, from: date))")
                    .font(.callout)
                    .fontWeight(isToday ? .bold : .regular)
                    .foregroundStyle(isSelected ? .white : isToday ? .blue : .primary)

                // 할일 존재 시 진행률 점 표시
                if hasTodos {
                    Circle()
                        .fill(completionColor(completionRate))
                        .frame(width: 5, height: 5)
                } else {
                    Circle()
                        .fill(.clear)
                        .frame(width: 5, height: 5)
                }
            }
            .frame(width: 36, height: 40)
            .background(
                Circle()
                    .fill(isSelected ? Color.blue : Color.clear)
                    .frame(width: 36, height: 36)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - 헬퍼

    /// 완료율에 따른 색상
    private func completionColor(_ rate: Double) -> Color {
        if rate >= 1.0 { return .green }
        if rate > 0 { return .orange }
        return .red.opacity(0.6)
    }

    /// 표시 월의 제목
    private var monthTitle: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy년 M월"
        return formatter.string(from: displayedMonth)
    }

    /// 월 이동
    private func moveMonth(_ value: Int) {
        withAnimation(.easeInOut(duration: 0.2)) {
            displayedMonth = calendar.date(byAdding: .month, value: value, to: displayedMonth) ?? displayedMonth
        }
    }

    /// 해당 월의 날짜 배열 생성 (빈 칸은 nil)
    private func makeDays() -> [Date?] {
        guard let range = calendar.range(of: .day, in: .month, for: displayedMonth),
              let firstOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: displayedMonth))
        else { return [] }

        // 첫째 날의 요일 (일=1 기준)
        let firstWeekday = calendar.component(.weekday, from: firstOfMonth)
        let leadingBlanks = firstWeekday - 1

        var days: [Date?] = Array(repeating: nil, count: leadingBlanks)

        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstOfMonth) {
                days.append(date)
            }
        }

        return days
    }
}

// MARK: - 년월 선택 시트

struct YearMonthPickerSheet: View {
    @Binding var selectedDate: Date
    @Binding var isPresented: Bool

    @State private var pickedYear: Int
    @State private var pickedMonth: Int

    private let yearRange = 1926...2126
    private let months = Array(1...12)

    init(selectedDate: Binding<Date>, isPresented: Binding<Bool>) {
        _selectedDate = selectedDate
        _isPresented = isPresented
        let cal = Calendar.current
        _pickedYear = State(initialValue: cal.component(.year, from: selectedDate.wrappedValue))
        _pickedMonth = State(initialValue: cal.component(.month, from: selectedDate.wrappedValue))
    }

    var body: some View {
        NavigationStack {
            HStack(spacing: 0) {
                // 년도 피커
                Picker("년도", selection: $pickedYear) {
                    ForEach(yearRange, id: \.self) { year in
                        Text("\(String(year))년").tag(year)
                    }
                }
                .pickerStyle(.wheel)

                // 월 피커
                Picker("월", selection: $pickedMonth) {
                    ForEach(months, id: \.self) { month in
                        Text("\(month)월").tag(month)
                    }
                }
                .pickerStyle(.wheel)
            }
            .navigationTitle("날짜 선택")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") { isPresented = false }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("확인") {
                        applySelection()
                        isPresented = false
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }

    private func applySelection() {
        var components = DateComponents()
        components.year = pickedYear
        components.month = pickedMonth
        components.day = 1
        if let date = Calendar.current.date(from: components) {
            selectedDate = date
        }
    }
}
