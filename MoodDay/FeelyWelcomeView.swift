import SwiftUI
import AVFoundation
import UIKit
import Combine

struct FeelyWelcomeView: View {
    let onCheckIn: () -> Void
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @StateObject private var playback = WelcomePlayback()
    @State private var manuallyPaused = false
    @State private var visible = false

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                Color.white
                if let poster = playback.poster {
                    Image(uiImage: poster)
                        .resizable()
                        .scaledToFill()
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .scaleEffect(1.24)
                        .clipped()
                        .accessibilityHidden(true)
                }
                WelcomePlayerSurface(player: playback.player)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .scaleEffect(1.24)
                    .clipped()
                    .accessibilityHidden(true)
                LinearGradient(stops: [
                    .init(color: .clear, location: 0.48),
                    .init(color: .white.opacity(0.08), location: 0.58),
                    .init(color: .white.opacity(0.90), location: 0.82),
                    .init(color: .white, location: 1)
                ], startPoint: .top, endPoint: .bottom)
                VStack(spacing: 12) {
                    Text("Feely")
                        .font(.custom("Caveat-Regular", size: 76, relativeTo: .largeTitle).weight(.semibold))
                        .accessibilityAddTraits(.isHeader)
                    Text("A little space for every **feeling**.")
                        .font(.system(size: 14))
                        .padding(.bottom, 16)
                    Button(action: onCheckIn) {
                        Text("Check in")
                            .font(.custom("Caveat-Regular", size: 24, relativeTo: .body).weight(.semibold))
                            .frame(maxWidth: .infinity, minHeight: 60)
                            .overlay(alignment: .trailing) {
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 18))
                                    .padding(.trailing, 22)
                                    .accessibilityHidden(true)
                            }
                            .foregroundStyle(.white)
                            .background(.black, in: RoundedRectangle(cornerRadius: 8))
                    }
                    .buttonStyle(.plain)
                    .accessibilityHint("Choose how you are feeling today")
                }
                .foregroundStyle(.black)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
                .padding(.bottom, max(32, geometry.safeAreaInsets.bottom + 20))
                .frame(maxWidth: 480)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .clipped()
            .overlay(alignment: .topTrailing) {
                Button {
                    manuallyPaused.toggle()
                    updatePlayback()
                } label: {
                    Image(systemName: playback.isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 13))
                        .foregroundStyle(.white)
                        .frame(width: 44, height: 44)
                        .background(.black.opacity(0.25), in: Circle())
                }
                .accessibilityLabel(playback.isPlaying ? "Pause background video" : "Play background video")
                .padding(.trailing, 18)
                .padding(.top, max(44, geometry.safeAreaInsets.top) + 12)
            }
        }
        .ignoresSafeArea()
        .onAppear {
            visible = true
            manuallyPaused = reduceMotion
            updatePlayback()
        }
        .onDisappear {
            visible = false
            playback.setPlaying(false)
        }
        .onChange(of: scenePhase) { _, _ in updatePlayback() }
        .onChange(of: reduceMotion) { _, value in
            manuallyPaused = value
            updatePlayback()
        }
    }

    private func updatePlayback() {
        playback.setPlaying(visible && scenePhase == .active && !manuallyPaused)
    }
}

@MainActor
private final class WelcomePlayback: ObservableObject {
    let player = AVQueuePlayer()
    let poster: UIImage?
    private var looper: AVPlayerLooper?
    @Published private(set) var isPlaying = false

    init() {
        poster = Bundle.main.url(forResource: "feely-background-v3", withExtension: "jpg", subdirectory: "WelcomeMedia")
            .flatMap { UIImage(contentsOfFile: $0.path) }
        player.isMuted = true
        player.preventsDisplaySleepDuringVideoPlayback = false
        if let url = Bundle.main.url(forResource: "feely-background-v3", withExtension: "mp4", subdirectory: "WelcomeMedia") {
            looper = AVPlayerLooper(player: player, templateItem: AVPlayerItem(url: url))
        }
    }

    func setPlaying(_ shouldPlay: Bool) {
        isPlaying = shouldPlay && looper != nil
        if isPlaying { player.play() } else { player.pause() }
    }
}

private struct WelcomePlayerSurface: UIViewRepresentable {
    let player: AVQueuePlayer

    func makeUIView(context: Context) -> WelcomePlayerView {
        let view = WelcomePlayerView()
        view.playerLayer.videoGravity = .resizeAspectFill
        view.playerLayer.player = player
        return view
    }

    func updateUIView(_ view: WelcomePlayerView, context: Context) {
        view.playerLayer.player = player
    }

    static func dismantleUIView(_ view: WelcomePlayerView, coordinator: ()) {
        view.playerLayer.player = nil
    }
}

private final class WelcomePlayerView: UIView {
    override class var layerClass: AnyClass { AVPlayerLayer.self }
    var playerLayer: AVPlayerLayer { layer as! AVPlayerLayer }
}
