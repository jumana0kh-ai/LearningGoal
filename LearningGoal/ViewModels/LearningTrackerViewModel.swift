


import Foundation
import Observation

@Observable
final class LearningTrackerViewModel {

    var learningGoal = ""
    var selectedDuration: LearningDuration = .week
    var currentGoal: LearningGoal?

    var canStartLearning: Bool {
        !learningGoal.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func startLearning() {
        guard canStartLearning else { return }

        currentGoal = LearningGoal(
            title: learningGoal.trimmingCharacters(in: .whitespacesAndNewlines),
            duration: selectedDuration
        )
    }
}
