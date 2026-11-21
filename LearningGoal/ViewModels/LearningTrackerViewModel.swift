
import Foundation
import Observation

@MainActor
@Observable
final class LearningTrackerViewModel {

    var learningGoal = ""

    var selectedDuration: LearningDuration = .week

    var currentGoal: LearningGoal?

    var canStartLearning: Bool {
        !learningGoal
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .isEmpty
    }

    func startLearning() {
        guard canStartLearning else {
            return
        }

        currentGoal = LearningGoal(
            title: learningGoal.trimmingCharacters(
                in: .whitespacesAndNewlines
            ),
            duration: selectedDuration
        )
    }

    func updateGoal(
        title: String,
        duration: LearningDuration
    ) {
        let trimmedTitle = title.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !trimmedTitle.isEmpty,
              currentGoal != nil else {
            return
        }

        currentGoal = LearningGoal(
            title: trimmedTitle,
            duration: duration,
            startDate: Date()
        )
    }
}
