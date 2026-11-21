//
//  ActivitiesCalendarView.swift
//  LearningGoal
//
//  Created by Jumanah on 07/06/1448 AH.
//

import SwiftUI

struct ActivitiesCalendarView: View {

    @Environment(\.dismiss) private var dismiss

    @State private var hasScrolledToCurrentMonth = false

    let goal: LearningGoal
    let days: [LearningDay]

    private let calendar = Calendar.current

    private let orange = Color(
        red: 1,
        green: 146.0 / 255.0,
        blue: 48.0 / 255.0
    )

    private let cyan = Color(
        red: 43.0 / 255.0,
        green: 201.0 / 255.0,
        blue: 239.0 / 255.0
    )

    private let darkSurface = Color(
        red: 26.0 / 255.0,
        green: 26.0 / 255.0,
        blue: 26.0 / 255.0
    )

    // MARK: - Months

    private var months: [Date] {

        let goalMonth = calendar.dateInterval(
            of: .month,
            for: goal.startDate
        )?.start ?? goal.startDate

        let currentMonth = calendar.dateInterval(
            of: .month,
            for: Date()
        )?.start ?? Date()

        let threeMonthStart = calendar.date(
            byAdding: .month,
            value: -2,
            to: currentMonth
        ) ?? currentMonth

        let start = min(goalMonth, threeMonthStart)

        let lastMonth = calendar.date(
            byAdding: .month,
            value: 12,
            to: currentMonth
        ) ?? currentMonth

        var result: [Date] = []
        var month = start

        while month <= lastMonth {
            result.append(month)

            guard let nextMonth = calendar.date(
                byAdding: .month,
                value: 1,
                to: month
            ) else {
                break
            }

            month = nextMonth
        }

        return result
    }

    var body: some View {
        VStack(spacing: 0) {

            header

            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(months, id: \.self) { month in
                            monthSection(month)
                                .id(month)
                        }
                    }
                    .padding(.top, 24)
                    .padding(.bottom, 32)
                }
                .scrollIndicators(.hidden)
                .onAppear {
                    guard !hasScrolledToCurrentMonth else {
                        return
                    }

                    let currentMonth = calendar.dateInterval(
                        of: .month,
                        for: Date()
                    )?.start ?? Date()

                    proxy.scrollTo(
                        currentMonth,
                        anchor: .top
                    )

                    hasScrolledToCurrentMonth = true
                }
            }
        }
        .background(Color.black.ignoresSafeArea())
        .preferredColorScheme(.dark)
    }

    // MARK: - Header

    private var header: some View {
        ZStack {

            Text("Activities")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)

            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(.white)
                        .frame(width: 40, height: 40)
                        .background {
                            Circle()
                                .fill(darkSurface)
                                .overlay {
                                    Circle()
                                        .strokeBorder(
                                            .white.opacity(0.15),
                                            lineWidth: 1
                                        )
                                }
                        }
                }

                Spacer()
            }
        }
        .frame(height: 44)
        .padding(.horizontal, 16)
        .padding(.top, 20)
    }

    // MARK: - Month Section

    private func monthSection(_ month: Date) -> some View {
        VStack(alignment: .leading, spacing: 12) {

            Text(
                month.formatted(
                    .dateTime.month(.wide).year()
                )
            )
            .font(.system(size: 14, weight: .medium))
            .foregroundStyle(.white)

            weekdayHeader

            monthGrid(month)
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(.white.opacity(0.14))
                .frame(height: 1)
        }
        .padding(.bottom, 16)
    }

    // MARK: - Weekday Header

    private var weekdayHeader: some View {
        HStack(spacing: 0) {
            ForEach(0..<7, id: \.self) { index in
                Text(weekdayName(at: index))
                    .font(.system(size: 10))
                    .foregroundStyle(.gray)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private func weekdayName(at index: Int) -> String {
        let weekdayIndex = (
            calendar.firstWeekday - 1 + index
        ) % 7

        return calendar.veryShortStandaloneWeekdaySymbols[
            weekdayIndex
        ].uppercased()
    }

    // MARK: - Month Grid

    private func monthGrid(_ month: Date) -> some View {
        let dates = calendarDates(for: month)

        return LazyVGrid(
            columns: Array(
                repeating: GridItem(
                    .flexible(),
                    spacing: 0
                ),
                count: 7
            ),
            spacing: 12
        ) {
            ForEach(Array(dates.enumerated()), id: \.offset) {
                _, date in

                if let date {
                    calendarDay(date)
                } else {
                    Color.clear
                        .frame(height: 36)
                }
            }
        }
    }

    private func calendarDates(for month: Date) -> [Date?] {
        guard
            let monthInterval = calendar.dateInterval(
                of: .month,
                for: month
            ),
            let dayRange = calendar.range(
                of: .day,
                in: .month,
                for: month
            )
        else {
            return []
        }

        let firstDay = monthInterval.start

        let firstWeekday = calendar.component(
            .weekday,
            from: firstDay
        )

        let leadingEmptyDays = (
            firstWeekday - calendar.firstWeekday + 7
        ) % 7

        var dates: [Date?] = Array(
            repeating: nil,
            count: leadingEmptyDays
        )

        for dayOffset in 0..<dayRange.count {
            let date = calendar.date(
                byAdding: .day,
                value: dayOffset,
                to: firstDay
            )

            dates.append(date)
        }

        return dates
    }

    // MARK: - Calendar Day

    private func calendarDay(_ date: Date) -> some View {

        let status = status(for: date)

        let isLearned = status == .learned
        let isFrozen = status == .frozen
        let isToday = calendar.isDateInToday(date)

        return Text(
            date.formatted(.dateTime.day())
        )
        .font(.system(size: 14, weight: .medium))
        .foregroundStyle(
            isLearned
                ? orange
                : isFrozen
                    ? cyan
                    : isToday
                        ? .white
                        : .white
        )
        .frame(maxWidth: .infinity)
        .frame(height: 36)
        .background {
            if isLearned {
                Circle()
                    .fill(orange.opacity(0.17))
                    .frame(width: 34, height: 34)

            } else if isFrozen {
                Circle()
                    .fill(cyan.opacity(0.17))
                    .frame(width: 34, height: 34)

            } else if isToday {
                Circle()
                    .fill(orange)
                    .frame(width: 34, height: 34)
            }
        }
    }

    // MARK: - Day Status

    private func status(for date: Date) -> DayStatus? {
        days.first {
            calendar.isDate(
                $0.date,
                inSameDayAs: date
            )
        }?.status
    }
}
