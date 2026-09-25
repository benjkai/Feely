import SwiftUI

struct HappySceneView: View {
    let celebration: Int
    let selected: Bool
    var sad = false
    var neutral = false
    var drag: CGFloat = 0
    let onSelect: () -> Void
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.scenePhase) private var scenePhase
    @State private var epoch = Date()
    @State private var reactionStarted: Date?

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0, paused: reduceMotion || scenePhase != .active)) { timeline in
            let time = reduceMotion ? 0 : timeline.date.timeIntervalSince(epoch)
            GeometryReader { geometry in
                let size = geometry.size
                ZStack {
                    scenery(size: size, time: time)
                        .saturation(sad ? 0.2 : 1)
                        .brightness(sad ? -0.15 : 0)
                        .offset(x: drag * 0.18)
                        .accessibilityHidden(true)

                    Ellipse()
                        .fill(Color.brown.opacity(0.15))
                        .frame(width: 120, height: 16)
                        .blur(radius: 7)
                        .opacity(0.6)
                        .position(x: size.width * 0.5, y: size.height * 0.97)
                        .accessibilityHidden(true)

                    MeadowParticles(time: time).opacity(sad || neutral ? 0 : 1)
                        .allowsHitTesting(false)
                        .accessibilityHidden(true)

                    Button(action: onSelect) {
                        ZStack {
                            HappyCharacterView(sad: false, selected: selected, time: time, reaction: reduceMotion ? -100 : reactionStarted.map { timeline.date.timeIntervalSince($0) } ?? -100)
                                .opacity(sad || neutral ? 0 : 1)
                            HappyCharacterView(neutral: true, selected: selected, time: time, reaction: -100)
                                .opacity(neutral ? 1 : 0)
                            HappyCharacterView(sad: true, selected: selected, time: time, reaction: reduceMotion ? -100 : reactionStarted.map { timeline.date.timeIntervalSince($0) } ?? -100)
                                .opacity(sad ? 1 : 0)
                        }
                        .frame(width: size.width * 1.02, height: size.height * 0.99)
                        .contentShape(Ellipse())
                        .offset(x: drag)
                    }
                    .buttonStyle(.plain)
                    .position(x: size.width * 0.5, y: size.height * 0.555)
                    .accessibilityLabel(neutral ? "Choose meh mood" : (sad ? "Choose down mood" : "Choose good mood"))
                    .accessibilityValue(selected ? "Selected" : "Not selected")
                    .accessibilityHint("Swipe left or right to explore moods. Tap to select or deselect.")
                    .accessibilityAddTraits(selected ? [.isSelected] : [])

                    RainView(time: time).opacity(sad ? 0.7 : 0).allowsHitTesting(false).accessibilityHidden(true)

                    DaisyView()
                        .frame(width: 35, height: 67)
                        .rotationEffect(.degrees(sin(time * 0.8) * 7), anchor: .bottom)
                        .position(x: size.width * 0.12, y: size.height * 0.92)
                        .accessibilityHidden(true)
                    DaisyView()
                        .frame(width: 28, height: 52)
                        .rotationEffect(.degrees(sin(time * 0.8 + 2) * 7), anchor: .bottom)
                        .position(x: size.width * 0.89, y: size.height * 0.94)
                        .accessibilityHidden(true)
                }
            }
        }
        .onChange(of: celebration) { _, _ in
            reactionStarted = reduceMotion ? nil : Date()
        }
        .onChange(of: selected) { _, value in
            if !value { reactionStarted = nil }
        }
        .onChange(of: reduceMotion) { _, value in
            if value { reactionStarted = nil }
        }
    }

    private func scenery(size: CGSize, time: Double) -> some View {
        ZStack {
            Circle()
                .fill(RadialGradient(colors: [Color(red: 1, green: 0.915, blue: 0.667), Color(red: 0.949, green: 0.808, blue: 0.467)], center: .topLeading, startRadius: 0, endRadius: 55))
                .frame(width: 53, height: 53)
                .shadow(color: .yellow.opacity(0.23), radius: 25)
                .opacity(sad || neutral ? 0 : 1)
                .overlay { Circle().stroke(MoodPalette.gold.opacity(0.13)).padding(-12) }
                .overlay { Circle().stroke(MoodPalette.gold.opacity(0.07)).padding(-25) }
                .scaleEffect(1 + sin(time * 1.25) * 0.04)
                .position(x: size.width * 0.79, y: size.height * 0.16)

            CloudView()
                .frame(width: 70, height: 31)
                .offset(x: sin(time * 0.18) * 20)
                .position(x: size.width * 0.16, y: size.height * 0.24)
            CloudView()
                .frame(width: 47, height: 22)
                .opacity(0.7)
                .offset(x: sin(time * 0.14 + 2) * 17)
                .position(x: size.width * 0.94, y: size.height * 0.37)

            ButterflyView(time: time).opacity(sad || neutral ? 0 : 1)
                .frame(width: 18, height: 15)
                .offset(x: sin(time * 0.8) * 10, y: cos(time * 0.8) * 12)
                .position(x: size.width * 0.12, y: size.height * 0.46)
            ButterflyView(time: time + 2).opacity(sad || neutral ? 0 : 1)
                .frame(width: 13, height: 11)
                .offset(x: sin(time * 0.8 + 2) * 8, y: cos(time * 0.8 + 2) * 10)
                .position(x: size.width * 0.87, y: size.height * 0.68)
        }
        .allowsHitTesting(false)
    }
}

private struct CloudView: View {
    var body: some View {
        GeometryReader { geometry in
            let w = geometry.size.width
            let h = geometry.size.height
            ZStack(alignment: .bottom) {
                Capsule().frame(height: h * 0.56)
                Ellipse().frame(width: w * 0.38, height: h * 0.83).offset(x: -w * 0.2, y: -h * 0.15)
                Ellipse().frame(width: w * 0.44, height: h).offset(x: w * 0.04, y: -h * 0.15)
                Ellipse().frame(width: w * 0.29, height: h * 0.68).offset(x: w * 0.28, y: -h * 0.12)
            }
            .foregroundStyle(Color(red: 1, green: 0.992, blue: 0.965))
            .shadow(color: .brown.opacity(0.08), radius: 5, y: 5)
        }
    }
}

private struct ButterflyView: View {
    let time: Double
    var body: some View {
        HStack(spacing: 0) {
            Ellipse().fill(Color(red: 0.898, green: 0.702, blue: 0.302))
                .rotationEffect(.degrees(-25))
                .scaleEffect(x: 0.65 + sin(time * 14) * 0.3, y: 1, anchor: .trailing)
            Ellipse().fill(Color(red: 0.953, green: 0.800, blue: 0.443))
                .rotationEffect(.degrees(25))
                .scaleEffect(x: 0.65 + sin(time * 14) * 0.3, y: 1, anchor: .leading)
        }
    }
}

private struct MeadowParticles: View {
    let time: Double
    var body: some View {
        Canvas { context, size in
            for i in 0..<15 {
                let duration = Double(5 + i % 5)
                let progress = (time / duration + Double(i) * 0.17).truncatingRemainder(dividingBy: 1)
                let x = size.width * Double(7 + (i * 37) % 87) / 100 + progress * 25
                let y = size.height * Double(26 + (i * 19) % 63) / 100 - progress * 66
                let opacity = max(0, sin(progress * .pi)) * 0.8
                let color = i.isMultiple(of: 3) ? Color(red: 0.93, green: 0.78, blue: 0.45) : Color.white
                context.fill(Path(ellipseIn: CGRect(x: x, y: y, width: 4, height: 3)), with: .color(color.opacity(opacity)))
            }
        }
    }
}

private struct DaisyView: View {
    var body: some View {
        Canvas { context, size in
            let center = CGPoint(x: size.width * 0.5, y: size.height * 0.3)
            var stem = Path()
            stem.move(to: CGPoint(x: size.width * 0.5, y: size.height))
            stem.addQuadCurve(to: center, control: CGPoint(x: size.width * 0.42, y: size.height * 0.6))
            context.stroke(stem, with: .color(MoodPalette.sage), lineWidth: 1.5)
            for angle in 0..<6 {
                var petalContext = context
                petalContext.translateBy(x: center.x, y: center.y)
                petalContext.rotate(by: .degrees(Double(angle) * 60))
                petalContext.fill(Path(ellipseIn: CGRect(x: -4, y: -16, width: 8, height: 16)), with: .color(.white))
            }
            context.fill(Path(ellipseIn: CGRect(x: center.x - 5, y: center.y - 5, width: 10, height: 10)), with: .color(Color(red: 0.9, green: 0.71, blue: 0.31)))
        }
    }
}

private struct RainView: View {
    let time: Double
    var body: some View {
        Canvas { context, size in
            for i in 0..<45 {
                let phase = (time / (0.8 + Double(i % 5) * 0.13) + Double(i) * 0.17).truncatingRemainder(dividingBy: 1)
                let x = size.width * Double((i * 37) % 100) / 100 - phase * 30
                let y = phase * size.height
                var drop = Path()
                drop.move(to: CGPoint(x: x, y: y))
                drop.addLine(to: CGPoint(x: x - 2, y: y + 15))
                context.stroke(drop, with: .color(Color(red: 0.63, green: 0.73, blue: 0.82)), lineWidth: 1)
            }
        }
        .mask(LinearGradient(colors: [.clear, .black, .black, .clear], startPoint: .top, endPoint: .bottom))
    }
}
