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

    // Used to refresh time-dependent values.
    var now = Date()

    init(goal: LearningGoal) {
        currentGoal = goal
        loadDays()
    }

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

    var canLogLearning: Bool {
        todayStatus == nil
    }

    var canFreeze: Bool {
        todayStatus == nil && remainingFreezes > 0
    }

    var currentStreak: Int {
        let ordered = days
            .filter { $0.date >= calendar.startOfDay(for: currentGoal.startDate) }
            .sorted { $0.date > $1.date }

        guard let latest = ordered.first else {
            return 0
        }

        let latestAction = latest.actionDate ?? latest.date

        // A streak expires after 32 hours without an action.
        guard now.timeIntervalSince(latestAction) <= 32 * 60 * 60 else {
            return 0
        }

        var streak = 0
        var previousDate: Date?

        for day in ordered {
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

            streak += 1
            previousDate = day.date
        }

        return streak
    }

    var learnedCount: Int {
        currentStreak
    }

    func status(for date: Date) -> DayStatus? {
        days.first {
            calendar.isDate(
                $0.date,
                inSameDayAs: date
            )
        }?.status
    }

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

