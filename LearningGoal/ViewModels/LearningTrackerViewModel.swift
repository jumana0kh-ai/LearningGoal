

import Foundation
import Observation

@Observable
final class OnboardingViewModel {

    var learningGoal: String = ""
    var selectedDuration: LearningDuration = .week
    var hasStarted: Bool = false

    var canStart: Bool {
        !learningGoal.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func startLearning() {
        guard canStart else { return }
        learningGoal = learningGoal.trimmingCharacters(in: .whitespacesAndNewlines)
        hasStarted = true
    }
}
