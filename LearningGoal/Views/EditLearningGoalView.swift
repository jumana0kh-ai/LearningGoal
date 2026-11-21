//
//  EditLearningGoalView.swift
//  LearningGoal
//
//  Created by Jumanah on 07/06/1448 AH.
//

import SwiftUI

struct EditLearningGoalView: View {

    @Environment(\.dismiss) private var dismiss

    @State private var goalTitle: String = ""
    @State private var selectedDuration: LearningDuration
    @State private var showUpdateAlert = false

    @FocusState private var isGoalFocused: Bool

    private let onUpdate: (String, LearningDuration) -> Void

    private let orange = Color(
        red: 1,
        green: 146.0 / 255.0,
        blue: 48.0 / 255.0
    )

    private let darkSurface = Color(
        red: 26.0 / 255.0,
        green: 26.0 / 255.0,
        blue: 26.0 / 255.0
    )

    init(
        goal: LearningGoal,
        onUpdate: @escaping (String, LearningDuration) -> Void
    ) {
        _selectedDuration = State(initialValue: goal.duration)
        self.onUpdate = onUpdate
    }

    private var canUpdate: Bool {
        !goalTitle
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .isEmpty
    }

    var body: some View {
        ZStack {

            VStack(alignment: .leading, spacing: 0) {

                navigationHeader

                VStack(alignment: .leading, spacing: 0) {

                    Text("I want to learn")
                        .font(.system(size: 16))
                        .foregroundStyle(.white)

                    TextField(
                        "",
                        text: $goalTitle,
                        prompt: Text("Swift")
                            .foregroundStyle(.gray)
                    )
                    .font(.system(size: 16))
                    .foregroundStyle(.white)
                    .tint(orange)
                    .focused($isGoalFocused)
                    .submitLabel(.done)
                    .padding(.top, 12)
                    .frame(height: 48)

                    Rectangle()
                        .fill(.white.opacity(0.16))
                        .frame(height: 1)

                    Text("I want to learn it in a")
                        .font(.system(size: 16))
                        .foregroundStyle(.white)
                        .padding(.top, 32)

                    HStack(spacing: 12) {
                        durationButton(.week, title: "Week")
                        durationButton(.month, title: "Month")
                        durationButton(.year, title: "Year")
                    }
                    .padding(.top, 16)
                }
                .padding(.top, 48)

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 16)

            if showUpdateAlert {
                Color.black.opacity(0.55)
                    .ignoresSafeArea()
                    .onTapGesture {
                        showUpdateAlert = false
                    }

                updateAlert
                    .padding(.horizontal, 32)
            }
        }
        .background(Color.black.ignoresSafeArea())
        .preferredColorScheme(.dark)
    }

    private var navigationHeader: some View {
        ZStack {

            Text("Learning Goal")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)

            HStack {

                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(.white)
                        .frame(width: 44, height: 44)
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

                Button {
                    isGoalFocused = false
                    showUpdateAlert = true
                } label: {
                    Image(systemName: "checkmark")
                        .font(.system(size: 22, weight: .medium))
                        .foregroundStyle(.white)
                        .frame(width: 44, height: 44)
                        .background(orange, in: Circle())
                }
                .disabled(!canUpdate)
                .opacity(canUpdate ? 1 : 0.5)
            }
        }
        .frame(height: 44)
    }

    private func durationButton(
        _ duration: LearningDuration,
        title: String
    ) -> some View {

        let isSelected = selectedDuration == duration

        return Button {
            selectedDuration = duration
        } label: {
            Text(title)
                .font(.system(size: 16))
                .foregroundStyle(
                    isSelected
                        ? Color.white
                        : Color.gray
                )
                .padding(.horizontal, 20)
                .frame(height: 46)
                .background {
                    Capsule()
                        .fill(
                            isSelected
                                ? orange
                                : darkSurface
                        )
                        .overlay {
                            Capsule()
                                .strokeBorder(
                                    .white.opacity(
                                        isSelected ? 0.3 : 0.12
                                    ),
                                    lineWidth: 1
                                )
                        }
                }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Custom Update Alert

    private var updateAlert: some View {
        VStack(alignment: .leading, spacing: 0) {

            Text("Update goal")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)

            Text("If you update now, your streak will start over.")
                .font(.system(size: 14))
                .foregroundStyle(.gray)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 8)

            HStack(spacing: 8) {

                Button {
                    showUpdateAlert = false
                } label: {
                    Text("Dismiss")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(
                            Color.white.opacity(0.12),
                            in: Capsule()
                        )
                }

                Button {
                    showUpdateAlert = false
                    onUpdate(goalTitle, selectedDuration)
                    dismiss()
                } label: {
                    Text("Update")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(orange, in: Capsule())
                }
            }
            .buttonStyle(.plain)
            .padding(.top, 20)
        }
        .padding(20)
        .frame(maxWidth: 360)
        .frame(minHeight: 170)
        .background {
            RoundedRectangle(cornerRadius: 28)
                .fill(darkSurface)
                .overlay {
                    RoundedRectangle(cornerRadius: 28)
                        .strokeBorder(
                            .white.opacity(0.18),
                            lineWidth: 1
                        )
                }
        }
    }
}
