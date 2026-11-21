
import SwiftUI

struct ActivityView: View {

    @State private var viewModel: ActivityViewModel

    @State private var showEditGoal = false
    @State private var showCalendar = false

    private let onSetNewGoal: () -> Void

    private let onUpdateGoal: (String, LearningDuration) -> Void

    init(
        goal: LearningGoal,
        onSetNewGoal: @escaping () -> Void = {},
        onUpdateGoal: @escaping (String, LearningDuration) -> Void = { _, _ in }
    ) {
        _viewModel = State(
            initialValue: ActivityViewModel(goal: goal)
        )

        self.onSetNewGoal = onSetNewGoal
        self.onUpdateGoal = onUpdateGoal
    }

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

    var body: some View {
        GeometryReader { geometry in

            let scale = min(
                geometry.size.width / 393,
                geometry.size.height / 812
            )

            ZStack {
                Color.black
                    .ignoresSafeArea()

                VStack(alignment: .leading, spacing: 0) {

                    header

                    weekCalendar
                        .padding(.top, 32)

                    statistics
                        .padding(.top, 16)

                    if viewModel.isGoalFinished {

                        Spacer(minLength: 24)

                        goalCompletionSection
                            .frame(maxWidth: .infinity)

                        Spacer(minLength: 24)

                    } else {

                        Spacer(minLength: 24)

                        learningButton
                            .frame(maxWidth: .infinity)

                        Spacer(minLength: 24)

                        freezeSection
                            .padding(.bottom, 38)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 20)
                .scaleEffect(scale, anchor: .top)
                .frame(
                    width: geometry.size.width / scale,
                    height: geometry.size.height / scale,
                    alignment: .top
                )
                .frame(
                    width: geometry.size.width,
                    height: geometry.size.height,
                    alignment: .top
                )
            }
        }
        .preferredColorScheme(.dark)
        .fullScreenCover(isPresented: $showEditGoal) {
            EditLearningGoalView(
                goal: viewModel.currentGoal,
                onUpdate: { title, duration in
                    onUpdateGoal(title, duration)
                }
            )
        }
        .fullScreenCover(isPresented: $showCalendar) {
            ActivitiesCalendarView(
                goal: viewModel.currentGoal,
                days: viewModel.days
            )
        }
        .onAppear {
            viewModel.refreshDate()
        }
        .onReceive(
            NotificationCenter.default.publisher(
                for: UIApplication.willEnterForegroundNotification
            )
        ) { _ in
            viewModel.refreshDate()
        }
        .onReceive(
            NotificationCenter.default.publisher(
                for: .NSCalendarDayChanged
            )
        ) { _ in
            viewModel.refreshDate()
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack(alignment: .top) {

            VStack(alignment: .leading, spacing: 4) {

                Text("Activity")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(.white)

                Text(
                    viewModel.now.formatted(
                        .dateTime
                            .weekday(.wide)
                            .day()
                            .month(.wide)
                    )
                )
                .font(.system(size: 14))
                .foregroundStyle(.gray)
            }

            Spacer()

            HStack(spacing: 12) {

                Button {
                    showCalendar = true
                } label: {
                    headerIcon("calendar")
                }
                .buttonStyle(.plain)

                Button {
                    showEditGoal = true
                } label: {
                    headerIcon("pencil.and.outline")
                }
                .buttonStyle(.plain)
            }
            .padding(.top, 4)
        }
    }

    private func headerIcon(_ symbol: String) -> some View {
        Image(systemName: symbol)
            .font(.system(size: 20, weight: .regular))
            .foregroundStyle(.white)
            .frame(width: 40, height: 40)
            .background {
                Circle()
                    .fill(darkSurface)
                    .overlay {
                        Circle()
                            .strokeBorder(
                                .white.opacity(0.13),
                                lineWidth: 1
                            )
                    }
            }
    }

    // MARK: - Week Calendar

    private var weekCalendar: some View {
        HStack(spacing: 0) {
            ForEach(viewModel.weekDates, id: \.self) { date in
                calendarDay(date)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private func calendarDay(_ date: Date) -> some View {

        let status = viewModel.status(for: date)

        let isToday = Calendar.current.isDate(
            date,
            inSameDayAs: viewModel.today
        )

        let isLearned = status == .learned
        let isFrozen = status == .frozen

        return VStack(spacing: 9) {

            Text(
                date.formatted(
                    .dateTime.weekday(.narrow)
                )
            )
            .font(.system(size: 12, weight: .medium))
            .foregroundStyle(.white)

            Text(
                date.formatted(.dateTime.day())
            )
            .font(.system(size: 18, weight: .medium))
            .foregroundStyle(
                isFrozen
                    ? cyan
                    : isLearned
                        ? orange
                        : isToday
                            ? .white
                            : .white
            )
            .frame(width: 40, height: 40)
            .background {

                if isFrozen {
                    Circle()
                        .fill(cyan.opacity(0.17))

                } else if isLearned {
                    Circle()
                        .fill(orange.opacity(0.17))

                } else if isToday {
                    Circle()
                        .fill(orange)
                }
            }
        }
    }

    // MARK: - Statistics

    private var statistics: some View {
        HStack(spacing: 12) {

            statisticCard(
                icon: "flame.fill",
                iconColor: orange,
                count: viewModel.learnedCount,
                title: "Learned"
            )

            statisticCard(
                icon: "snowflake",
                iconColor: cyan,
                count: viewModel.frozenCount,
                title: "Freezed"
            )
        }
    }

    private func statisticCard(
        icon: String,
        iconColor: Color,
        count: Int,
        title: String
    ) -> some View {

        VStack(spacing: 5) {

            Image(systemName: icon)
                .font(.system(size: 21, weight: .semibold))
                .foregroundStyle(iconColor)

            Text("\(count) \(count == 1 ? "day" : "days")")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.white)

            Text(title)
                .font(.system(size: 12))
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 102)
        .background {
            RoundedRectangle(cornerRadius: 34)
                .fill(darkSurface)
                .overlay {
                    RoundedRectangle(cornerRadius: 34)
                        .strokeBorder(
                            LinearGradient(
                                colors: [
                                    .white.opacity(0.28),
                                    .white.opacity(0.04),
                                    .white.opacity(0.16)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 1
                        )
                }
                .shadow(
                    color: .white.opacity(0.07),
                    radius: 2,
                    y: -1
                )
                .shadow(
                    color: .black.opacity(0.45),
                    radius: 10,
                    y: 5
                )
        }
    }

    // MARK: - Main Learning Button

    private var learningButton: some View {

        let isDisabled = !viewModel.canLogLearning

        return Button {
            viewModel.logAsLearned()
        } label: {

            Text(
                isDisabled
                    ? "Logged as Learned"
                    : "Log as Learned"
            )
            .font(.system(size: 16, weight: .semibold))
            .foregroundStyle(
                isDisabled
                    ? Color.gray.opacity(0.48)
                    : .white
            )
            .frame(width: 272, height: 272)
            .background {
                Circle()
                    .fill(
                        isDisabled
                            ? darkSurface
                            : orange
                    )
                    .overlay {
                        Circle()
                            .strokeBorder(
                                isDisabled
                                    ? .white.opacity(0.12)
                                    : .white.opacity(0.18),
                                lineWidth: 1
                            )
                    }
                    .shadow(
                        color: .black.opacity(0.35),
                        radius: 7,
                        y: 3
                    )
            }
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
    }

    // MARK: - Freeze

    private var freezeSection: some View {

        let isDisabled = !viewModel.canFreeze

        return VStack(spacing: 12) {

            Button {
                viewModel.freezeDay()
            } label: {

                Text(
                    isDisabled
                        ? "Freezed for a day"
                        : "Freeze for a day"
                )
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(
                    isDisabled
                        ? .gray.opacity(0.55)
                        : .white
                )
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background {
                    Capsule()
                        .fill(
                            isDisabled
                                ? darkSurface
                                : cyan
                        )
                        .overlay {
                            Capsule()
                                .strokeBorder(
                                    .white.opacity(
                                        isDisabled ? 0.10 : 0.25
                                    ),
                                    lineWidth: 1
                                )
                        }
                }
            }
            .buttonStyle(.plain)
            .disabled(isDisabled)

            Text(
                "\(viewModel.frozenCount) out of \(viewModel.maxFreezes) Freezes used"
            )
            .font(.system(size: 12))
            .foregroundStyle(.gray)
        }
        .padding(.horizontal, 40)
    }

    // MARK: - Goal Completion

    private var goalCompletionSection: some View {
        VStack(spacing: 0) {

            Image(
                systemName: viewModel.isGoalCompleted
                    ? "hands.clap.fill"
                    : "xmark.seal.fill"
            )
            .font(.system(size: 40))
            .foregroundStyle(orange)
            .frame(width: 50, height: 51)

            Text(
                viewModel.isGoalCompleted
                    ? "Well done!"
                    : "You didn't reach your goal this time."
            )
            .font(.system(size: 16, weight: .semibold))
            .foregroundStyle(.white)
            .padding(.top, 8)

            Text(
                viewModel.isGoalCompleted
                    ? "Ready for your next goal?"
                    : "Want to set another goal?"
            )
            .font(.system(size: 14))
            .foregroundStyle(.gray)
            .padding(.top, 4)

            Button {
                onSetNewGoal()
            } label: {
                Label(
                    "Set a goal",
                    systemImage: "scope"
                )
                .font(.system(size: 16))
                .foregroundStyle(.white)
                .frame(height: 50)
                .padding(.horizontal, 20)
                .background(
                    orange,
                    in: Capsule()
                )
            }
            .buttonStyle(.plain)
            .padding(.top, 64)
        }
    }
}

// MARK: - Preview

#Preview("Activity - Default") {
    ActivityView(
        goal: LearningGoal(
            title: "Swift",
            duration: .week
        )
    )
    .preferredColorScheme(.dark)
}
