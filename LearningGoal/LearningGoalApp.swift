//
//  LearningGoalApp.swift
//  LearningGoal
//
//  Created by Jumanah on 06/06/1448 AH.
//

import SwiftUI

@main
struct LearningGoalApp: App {

    @State private var viewModel = LearningTrackerViewModel()

    var body: some Scene {
        WindowGroup {
            if let goal = viewModel.currentGoal {
                ActivityView(
                    goal: goal,
                    onSetNewGoal: {
                        viewModel.learningGoal = ""
                        viewModel.selectedDuration = .week
                        viewModel.currentGoal = nil
                    },
                    onUpdateGoal: { title, duration in
                        viewModel.updateGoal(
                            title: title,
                            duration: duration
                        )
                    }
                )
                .id(goal.id)
                .preferredColorScheme(.dark)
            } else {
                OnboardingView(viewModel: viewModel)
                    .preferredColorScheme(.dark)
            }
        }
    }
}
