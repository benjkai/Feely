import SwiftUI

/// Original Happy image with blinking eyes, gentle float, and tap-to-hop feedback.
struct HappyCharacterView: View {
    var sad = false
    var neutral = false
    var selected = false
    let time: Double
    let reaction: Double
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Canvas { context, size in
            let side = min(size.width, size.height)
            var artwork = context
            artwork.translateBy(x: (size.width - side) / 2, y: (size.height - side) / 2)
            artwork.scaleBy(x: side / 1254, y: side / 1254)
            artwork.draw(context.resolve(Image(neutral ? "NeutralAvatar" : (sad ? "SadAvatar" : "HappyAvatar"))), in: CGRect(x: 0, y: 0, width: 1254, height: 1254))
            let natural = pulse(time.truncatingRemainder(dividingBy: 5.3), center: 4.6)
            let tapped = pulse(reaction, center: 0.14)
            let closed = reduceMotion ? 0 : max(natural, tapped)
            if closed > 0 && !sad && !neutral {
                drawLid(in: artwork, x: 570, y: 284, rx: 82, ry: 55, angle: 9,
                        top: Color(red: 52/255.0, green: 51/255.0, blue: 49/255.0),
                        bottom: Color(red: 36/255.0, green: 36/255.0, blue: 35/255.0), closed: closed)
                drawLid(in: artwork, x: 799, y: 335, rx: 86, ry: 58, angle: 16,
                        top: Color(white: 41/255.0),
                        bottom: Color(red: 30/255.0, green: 31/255.0, blue: 31/255.0), closed: closed)
            }
        }
        .rotationEffect(.degrees(reduceMotion ? 0 : sin(time * 1.43) * (selected ? 4 : 2.5) - 0.5))
        .offset(y: reduceMotion ? 0 : sin(time * 1.43) * (selected ? 14 : 6))
        .scaleEffect(reduceMotion ? 1 : 1 + sin(time * 1.43) * (selected ? 0.025 : 0.012))
        .scaleEffect(x: reduceMotion ? 1 : 1 + hopProgress * 0.025,
                     y: reduceMotion ? 1 : 1 - hopProgress * 0.015)
        .offset(y: reduceMotion ? 0 : -hopProgress * 32)
        .shadow(color: Color.white.opacity(selected ? 0.8 : 0), radius: 3)
        .shadow(color: (sad ? Color(red: 0.8, green: 0.9, blue: 1) : Color(red: 1, green: 0.88, blue: 0.6)).opacity(selected ? 0.85 : 0), radius: 15)
        .accessibilityHidden(true)
    }

    private var hopProgress: Double {
        guard reaction >= 0, reaction < 0.9 else { return 0 }
        return sin(reaction / 0.9 * .pi)
    }

    private func pulse(_ phase: Double, center: Double) -> Double {
        max(0, 1 - abs(phase - center) / 0.14)
    }

    private func drawLid(in context: GraphicsContext, x: Double, y: Double,
                         rx: Double, ry: Double, angle: Double, top: Color, bottom: Color, closed: Double) {
        var lid = context
        lid.translateBy(x: x, y: y)
        lid.rotate(by: .degrees(angle))
        lid.clip(to: Path(ellipseIn: CGRect(x: -rx, y: -ry, width: rx * 2, height: ry * 2)))
        lid.fill(Path(CGRect(x: -rx, y: -ry, width: rx * 2, height: ry * 2 * closed)),
                 with: .linearGradient(Gradient(colors: [top, bottom]),
                                       startPoint: CGPoint(x: 0, y: -ry), endPoint: CGPoint(x: 0, y: ry)))
    }
}
