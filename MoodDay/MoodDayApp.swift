import SwiftUI
import CoreText

@main
struct MoodDayApp: App {
    init() {
        for name in ["AnonymousPro-Bold", "Caveat"] {
            if let url = Bundle.main.url(forResource: name, withExtension: "ttf", subdirectory: "Fonts") {
                CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
            }
        }
    }

    var body: some Scene {
        WindowGroup {
            FeelyAppRoot()
                .preferredColorScheme(.light)
        }
    }
}

private struct FeelyAppRoot: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var checkingIn = false

    var body: some View {
        ZStack {
            if checkingIn {
                CheckInPreviewHost()
                    .transition(reduceMotion ? .identity : .opacity.combined(with: .offset(y: 24)))
            } else {
                FeelyWelcomeView {
                    withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.46)) {
                        checkingIn = true
                    }
                }
                .transition(reduceMotion ? .identity : .opacity.combined(with: .offset(y: -12)))
            }
        }
    }
}

/// A single-screen host. Replace the confirmation with step two when it is designed.
private struct CheckInPreviewHost: View {
    @State private var showConfirmation = false
    @State private var mood = 0
    private var sad: Bool { mood == 2 }

    var body: some View {
        HappyCheckInView { value in mood = value; showConfirmation = true }
            .sheet(isPresented: $showConfirmation) {
                VStack(spacing: 20) {
                    Image(systemName: ["sun.max.fill", "cloud.fill", "cloud.rain.fill"][mood])
                        .font(.system(size: 42))
                        .foregroundStyle(MoodPalette.gold)
                    Text("YOUR CHECK-IN")
                        .font(.caption2.weight(.semibold))
                        .tracking(3)
                        .foregroundStyle(MoodPalette.gold)
                    Text(["You’re feeling good.", "You’re feeling meh.", "You’re feeling down."][mood])
                        .font(.system(.title, design: .serif))
                    Text(mood == 1 ? "Taking the day as it comes." : sad ? "Every feeling deserves a little kindness.\nTake your time." : "A little joy, noticed.\nTake that sunshine with you.")
                        .font(.system(.body, design: .serif))
                        .foregroundStyle(MoodPalette.muted)
                        .multilineTextAlignment(.center)
                    Button("Back to check-in") { showConfirmation = false }
                        .buttonStyle(MoodActionStyle(primary: true))
                }
                .padding(.horizontal, 28)
                .padding(.top, 28)
                .padding(.bottom, 32)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .foregroundStyle(MoodPalette.ink)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
                .presentationBackground(MoodPalette.cream)
            }
    }
}

enum MoodPalette {
    static let cream = Color(red: 1, green: 0.973, blue: 0.910)
    static let ink = Color(red: 0.188, green: 0.180, blue: 0.141)
    static let muted = Color(red: 0.545, green: 0.475, blue: 0.357)
    static let gold = Color(red: 0.655, green: 0.522, blue: 0.255)
    static let line = Color(red: 0.847, green: 0.788, blue: 0.639)
    static let sage = Color(red: 0.412, green: 0.482, blue: 0.298)
}
