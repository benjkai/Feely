import SwiftUI

struct HappyCheckInView: View {
    var onContinue: (Int) -> Void
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @ScaledMetric(relativeTo: .body) private var descriptionSize: CGFloat = 14
    @State private var chosen: Int?
    @State private var mood = 0
    private var sad: Bool { mood == 2 }
    private var neutral: Bool { mood == 1 }
    @GestureState private var drag: CGFloat = 0
    private var selected: Bool { chosen == mood }
    @State private var celebration = 0

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 0) {
                    header
                        .padding(.top, 16)

                    caption
                        .padding(.top, 36)
                        .padding(.bottom, 8)

                    HappySceneView(celebration: celebration, selected: selected, sad: sad, neutral: neutral, drag: drag, onSelect: selectHappy)
                        .frame(height: sceneHeight(geometry.size.height))
                        .simultaneousGesture(DragGesture(minimumDistance: 15).updating($drag) { value, state, _ in
                            if abs(value.translation.width) > abs(value.translation.height) { state = value.translation.width * 0.3 }
                        }.onEnded { value in
                            guard abs(value.translation.width) > 45, abs(value.translation.width) > abs(value.translation.height) else { return }
                            withAnimation(reduceMotion ? nil : .spring(response: 0.65, dampingFraction: 0.85)) { mood = min(2, max(0, mood + (value.translation.width < 0 ? 1 : -1))) }
                        })
                        .accessibilityAction(named: "Next mood") { withAnimation { mood = min(2, mood + 1) } }
                        .accessibilityAction(named: "Previous mood") { withAnimation { mood = max(0, mood - 1) } }

                    Spacer(minLength: 18)

                    ZStack {
                        Color.clear.frame(height: 60)
                        if selected {
                            Button("Next") { onContinue(mood) }
                                .buttonStyle(MoodActionStyle(primary: true, fontSize: 24, primaryColor: .black))
                                .accessibilityHint("Continue with your selected mood")
                                .transition(.opacity)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, max(0, 32 - geometry.safeAreaInsets.bottom))
                }
                .frame(maxWidth: 480)
                .frame(minHeight: geometry.size.height)
                .frame(maxWidth: .infinity)
            }
            .scrollIndicators(.hidden)
        }
        .background {
            GeometryReader { backgroundGeometry in
                Image(neutral ? "NeutralMeadow" : "HappyMeadow")
                    .resizable()
                    .scaledToFill()
                    .frame(width: backgroundGeometry.size.width, height: backgroundGeometry.size.height)
                    .clipped()
                    .saturation(sad ? 0.2 : 1)
                    .brightness(sad ? -0.15 : 0)
            }
            .ignoresSafeArea()
        }
        .foregroundStyle(MoodPalette.ink)
        .sensoryFeedback(.selection, trigger: selected)

    }

    private func sceneHeight(_ availableHeight: CGFloat) -> CGFloat {
        // Keep controls reachable on small devices; allow scrolling with larger text.
        if dynamicTypeSize.isAccessibilitySize { return 280 }
        return min(420, max(250, availableHeight - 390))
    }

    private var header: some View {
        VStack(spacing: 0) {
            HStack(spacing: 7) {
                ForEach(0..<3) { step in
                    Circle()
                        .fill(step == 0 ? MoodPalette.ink : (sad || neutral ? Color.white : MoodPalette.line))
                        .frame(width: 6, height: 6)
                }
            }
            .accessibilityHidden(true)
            .padding(.bottom, 12)
            Text("How are you\nfeeling today?")
                .font(.custom("Caveat-Regular", size: 26, relativeTo: .largeTitle).weight(.semibold))
                .tracking(0)
                .multilineTextAlignment(.center)
                .accessibilityAddTraits(.isHeader)

        }
        .padding(.horizontal, 24)
    }

    private var caption: some View {
        VStack(alignment: .center, spacing: 3) {
            Button(action: selectHappy) {
                Text(["Good", "Meh", "Down"][mood])
                    // Figma Hand is not bundled; Caveat is the explicit temporary fallback.
                    .font(.custom("Caveat-Regular", size: 44, relativeTo: .title))
                    .multilineTextAlignment(.center)
                    .frame(minHeight: 44)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(["Good mood", "Meh mood", "Down mood"][mood])
            .accessibilityValue(selected ? "Selected" : "Not selected")
            .accessibilityAddTraits(selected ? [.isSelected] : [])
            Text(["Inside and out.", "Taking the day as it comes.", "A little rain. It’s okay to feel this way."][mood])
                .font(.system(size: descriptionSize))
                .foregroundStyle(MoodPalette.ink)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.horizontal, 20)
    }

    private func selectHappy() {
        withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.2)) {
            chosen = selected ? nil : mood
        }
        if selected { celebration += 1 }
    }
}

struct MoodActionStyle: ButtonStyle {
    let primary: Bool
    var fontSize: CGFloat = 16
    var primaryColor: Color = MoodPalette.ink
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.custom("Caveat-Regular", size: fontSize).weight(.semibold))
            .frame(maxWidth: .infinity)
            .frame(height: 60)
            .foregroundStyle(primary ? MoodPalette.cream : MoodPalette.muted)
            .background(primary ? primaryColor : .clear, in: RoundedRectangle(cornerRadius: 8))
            .overlay {
                if !primary {
                    RoundedRectangle(cornerRadius: 8).strokeBorder(MoodPalette.line, lineWidth: 1.5)
                }
            }
            .opacity(isEnabled ? 1 : 0.5)
            .scaleEffect(configuration.isPressed && !reduceMotion ? 0.97 : 1)
    }
}

#Preview("Happy · iPhone") {
    HappyCheckInView(onContinue: { _ in })
}

#Preview("Happy · Large Text") {
    HappyCheckInView(onContinue: { _ in })
        .environment(\.dynamicTypeSize, .accessibility2)
}
