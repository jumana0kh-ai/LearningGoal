



import SwiftUI

struct OnboardingView: View {

    @Bindable var viewModel: LearningTrackerViewModel

    private let orange = Color(
        red: 255 / 255,
        green: 146 / 255,
        blue: 48 / 255
    )

    private let darkGray = Color(
        red: 26 / 255,
        green: 26 / 255,
        blue: 26 / 255
    )

    var body: some View {
        GeometryReader { geometry in

            let scale = geometry.size.height / 812

            ZStack(alignment: .top) {

                Color.black
                    .ignoresSafeArea()

                // MARK: - Logo

                Image(systemName: "flame.fill")
                    .font(.system(size: 43, weight: .bold))
                    .foregroundStyle(orange)
                    .frame(maxWidth: .infinity)
                    .position(
                        x: geometry.size.width / 2,
                        y: 138 * scale
                    )

                // MARK: - Main Content

                VStack(alignment: .leading, spacing: 0) {

                    (
                        Text("Hello ")
                            .fontWeight(.regular)
                        +
                        Text("Learner")
                            .fontWeight(.bold)
                    )
                    .font(.system(size: 34))
                    .foregroundStyle(.white)

                    Text("This app will help you learn everyday!")
                        .font(.system(size: 17))
                        .foregroundStyle(.gray)
                        .padding(.top, 4)

                    Text("I want to learn")
                        .font(.system(size: 16))
                        .foregroundStyle(.white)
                        .padding(.top, 44)

                    TextField(
                        "Swift",
                        text: $viewModel.learningGoal
                    )
                    .font(.system(size: 17))
                    .foregroundStyle(.white)
                    .tint(orange)
                    .padding(.top, 16)
                    .padding(.bottom, 12)

                    Rectangle()
                        .fill(Color.white.opacity(0.12))
                        .frame(height: 1)

                    Text("I want to learn it in a")
                        .font(.system(size: 16))
                        .foregroundStyle(.white)
                        .padding(.top, 32)

                    HStack(spacing: 12) {

                        ForEach(LearningDuration.allCases) { duration in

                            let isSelected =
                                viewModel.selectedDuration == duration

                            Button {
                                viewModel.selectedDuration = duration
                            } label: {

                                Text(duration.rawValue)
                                    .font(.system(size: 17))
                                    .foregroundStyle(
                                        isSelected
                                        ? Color.white
                                        : Color.gray
                                    )
                                    .padding(.horizontal, 22)
                                    .frame(height: 46)
                                    .background {
                                        Capsule()
                                            .fill(
                                                isSelected
                                                ? orange
                                                : darkGray
                                            )
                                    }
                                    .overlay {
                                        Capsule()
                                            .strokeBorder(
                                                Color.white.opacity(
                                                    isSelected ? 0.25 : 0.10
                                                ),
                                                lineWidth: 0.7
                                            )
                                    }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.top, 12)
                }
                .padding(.horizontal, 17)
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
                .position(
                    x: geometry.size.width / 2,
                    y: 390 * scale
                )

                // MARK: - Bottom Button

                VStack(spacing: 12) {

                    Button {
                        viewModel.startLearning()
                    } label: {

                        Text("Start Learning")
                            .font(.system(
                                size: 17,
                                weight: .medium
                            ))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 24)
                            .frame(height: 46)
                            .background {
                                Capsule()
                                    .fill(orange)
                            }
                            .overlay {
                                Capsule()
                                    .strokeBorder(
                                        Color.white.opacity(0.20),
                                        lineWidth: 0.7
                                    )
                            }
                    }
                    .buttonStyle(.plain)

                    Text("You can edit your desire later")
                        .font(.system(size: 12))
                        .foregroundStyle(.gray)
                }
                .frame(maxWidth: .infinity)
                .position(
                    x: geometry.size.width / 2,
                    y: geometry.size.height - 48
                )
            }
            .frame(
                width: geometry.size.width,
                height: geometry.size.height
            )
        }
        .background(Color.black.ignoresSafeArea())
        .preferredColorScheme(.dark)
    }
}

#Preview {
    OnboardingView(
        viewModel: LearningTrackerViewModel()
    )
}
