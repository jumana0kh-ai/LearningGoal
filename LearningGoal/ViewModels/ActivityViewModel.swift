//
//  ActivityViewModel.swift
//  LearningGoal
//
//  Created by Jumanah on 06/06/1448 AH.
//

import Foundation
import Observation

@MainActor
@Observable
final class ActivityViewModel {

    let currentGoal: LearningGoal

    private(set) var days: [LearningDay] = []

    private let calendar = Calendar.current

    var now = Date()

    init(goal: LearningGoal) {
        self.currentGoal = goal
        loadDays()
    }

    // MARK: - Dates

    var today: Date {
        calendar.startOfDay(for: now)
    }

    var weekDates: [Date] {
        guard let interval = calendar.dateInterval(
            of: .weekOfYear,
            for: today
        ) else {
            return [today]
        }

        return (0..<7).compactMap { offset in
            calendar.date(
                byAdding: .day,
                value: offset,
                to: interval.start
            )
        }
    }

    var todayStatus: DayStatus? {
        status(for: today)
    }

    // MARK: - Freezes

    var maxFreezes: Int {
        currentGoal.duration.allowedFreezes
    }

    var frozenCount: Int {
        days.filter {
            $0.status == .frozen
        }.count
    }

    var remainingFreezes: Int {
        max(0, maxFreezes - frozenCount)
    }

    // MARK: - Streak

    var currentStreak: Int {
        let orderedDays = days.sorted {
            $0.date > $1.date
        }

        guard let latestDay = orderedDays.first else {
            return 0
        }

        let lastAction = latestDay.actionDate ?? latestDay.date

        guard now.timeIntervalSince(lastAction) <= 32 * 60 * 60 else {
            return 0
        }

        var streak = 0
        var previousDate: Date?

        for day in orderedDays {

            if let previousDate {
                let difference = calendar.dateComponents(
                    [.day],
                    from: calendar.startOfDay(for: day.date),
                    to: calendar.startOfDay(for: previousDate)
                ).day ?? 0

                guard difference == 1 else {
                    break
                }
            }

            // Frozen days maintain continuity
            // without adding to Learned.
            if day.status == .learned {
                streak += 1
            }

            previousDate = day.date
        }

        return streak
    }

    var learnedCount: Int {
        currentStreak
    }

    // MARK: - Goal Completion

    private var effectiveStartDate: Date {
        currentGoal.startDate
    }

    var goalEndDate: Date {
        let startDate = calendar.startOfDay(
            for: effectiveStartDate
        )

        switch currentGoal.duration {
        case .week:
            return calendar.date(
                byAdding: .day,
                value: 7,
                to: startDate
            ) ?? startDate

        case .month:
            return calendar.date(
                byAdding: .month,
                value: 1,
                to: startDate
            ) ?? startDate

        case .year:
            return calendar.date(
                byAdding: .year,
                value: 1,
                to: startDate
            ) ?? startDate
        }
    }

    var isGoalFinished: Bool {
        today >= goalEndDate
    }

    var isGoalCompleted: Bool {
        guard isGoalFinished else {
            return false
        }

        var date = calendar.startOfDay(
            for: effectiveStartDate
        )

        while date < goalEndDate {
            guard let dayStatus = status(for: date),
                  dayStatus == .learned || dayStatus == .frozen else {
                return false
            }

            guard let nextDate = calendar.date(
                byAdding: .day,
                value: 1,
                to: date
            ) else {
                return false
            }

            date = nextDate
        }

        return true
    }

    // MARK: - Button States

    var canLogLearning: Bool {
        !isGoalFinished && todayStatus == nil
    }

    var canFreeze: Bool {
        !isGoalFinished &&
        todayStatus == nil &&
        remainingFreezes > 0
    }

    // MARK: - Day Status

    func status(for date: Date) -> DayStatus? {
        days.first {
            calendar.isDate(
                $0.date,
                inSameDayAs: date
            )
        }?.status
    }

    // MARK: - Actions

    func logAsLearned() {
        guard canLogLearning else {
            return
        }

        days.append(
            LearningDay(
                date: today,
                status: .learned,
                actionDate: now
            )
        )

        saveDays()
    }

    func freezeDay() {
        guard canFreeze else {
            return
        }

        days.append(
            LearningDay(
                date: today,
                status: .frozen,
                actionDate: now
            )
        )

        saveDays()
    }

    func refreshDate() {
        now = Date()
    }

    // MARK: - Storage

    private var storageKey: String {
        "learningDays_\(currentGoal.id.uuidString)"
    }

    private func saveDays() {
        guard let data = try? JSONEncoder().encode(days) else {
            return
        }

        UserDefaults.standard.set(
            data,
            forKey: storageKey
        )
    }

    private func loadDays() {
        guard
            let data = UserDefaults.standard.data(
                forKey: storageKey
            ),
            let saved = try? JSONDecoder().decode(
                [LearningDay].self,
                from: data
            )
        else {
            return
        }

        days = saved
    }
}
