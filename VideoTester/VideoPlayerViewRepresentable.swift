//
//  VideoPlayerViewRepresentable.swift
//  VideoTester
//
//  Created by David Bage on 03/06/2023.
//

import Foundation
import SwiftUI
import AVKit
import Combine

 struct VideoPlayerViewRepresentable: UIViewControllerRepresentable {
    @EnvironmentObject private var videoPlayerEnvironmentObject: VideoPlayerEnvironmentObject

    @Binding var shouldPlayVideo: Bool
    @Binding var didError: Bool
    @Binding var didFinishPlayingVideo: Bool
    @Binding var moveTo: Double

    let videoURL: URL
    let backgroundColour: UIColor

    var isFullScreenGallery: Bool = false

    static func dismantleUIViewController(_ uiViewController: AVPlayerViewController, coordinator: Coordinator) {
        uiViewController.player?.removeObserver(coordinator, forKeyPath: #keyPath(AVPlayer.currentItem.status))

        if !coordinator.isFullScreenGallery {
            uiViewController.player?.replaceCurrentItem(with: nil)
        }

        coordinator.cancellable?.cancel()
        coordinator.playerDurationObservation?.invalidate()
    }

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let player = videoPlayerEnvironmentObject.player(for: videoURL)

        let playerViewController = AVPlayerViewController()
        playerViewController.view.backgroundColor = backgroundColour
        playerViewController.videoGravity = .resizeAspectFill
        playerViewController.player = player
        playerViewController.delegate = context.coordinator
        context.coordinator.isFullScreenGallery = isFullScreenGallery
        playerViewController.showsPlaybackControls = false
        player?.rate = 0

        context.coordinator.playerDurationObservation = player?.currentItem?.observe(\.status, options: [.initial, .new]) { (playerItem, _) in
            switch playerItem.status {
            case .readyToPlay:
                playerItem.seek(to: CMTimeMultiplyByFloat64(playerItem.duration, multiplier: 0.5), completionHandler: nil)
            case .failed:
                didError = true
            default:
                break
            }
        }

        return playerViewController
    }

    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        guard let duration = uiViewController.player?.currentItem?.duration,
              duration != .indefinite else {
            return
        }

        let timestampToSeekTo = CMTimeMultiplyByFloat64(duration, multiplier: Float64(moveTo))
        uiViewController.player?.seek(to: timestampToSeekTo, toleranceBefore: .zero, toleranceAfter: .zero)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(didError: $didError)
    }

    final class Coordinator: NSObject, AVPlayerViewControllerDelegate {
        @Binding private var didError: Bool

        var cancellable: AnyCancellable?
        var isFullScreenGallery: Bool = false
        var timeObserverToken: Any?
        var playerDurationObservation: NSKeyValueObservation?
        var playerErrorObservation: NSKeyValueObservation?

        init(didError: Binding<Bool>) {
            self._didError = didError
        }

        func playerViewController(_ playerViewController: AVPlayerViewController,
                                  willBeginFullScreenPresentationWithAnimationCoordinator coordinator: UIViewControllerTransitionCoordinator) {
            playerViewController.showsPlaybackControls = true
        }

        func playerViewController(_ playerViewController: AVPlayerViewController,
                                  willEndFullScreenPresentationWithAnimationCoordinator coordinator: UIViewControllerTransitionCoordinator) {
            coordinator.animate(alongsideTransition: nil) { _ in
//                playerViewController.player?.play()
            }
        }
    }
 }

final class VideoPlayerEnvironmentObject: ObservableObject {
    private var player: AVPlayer?

    func preloadVideo(for url: URL?) {
        guard let videoURL = url, player == nil else { return }

        if let video360 = Bundle.main.url(forResource: "Spin_example", withExtension: "mp4") {
            player = AVPlayer(url: video360)

        } else {
            let item = AVPlayerItem(url: videoURL)
            player = AVPlayer(playerItem: item)
        }
        player?.isMuted = true
    }

    func player(for url: URL?) -> AVPlayer? {
        guard let url = url else { return nil }

        if let player = player, (player.currentItem?.asset as? AVURLAsset)?.url == url {
            return player

        } else {
            if let video360 = Bundle.main.url(forResource: "Spin_example", withExtension: "mp4") {
                player = AVPlayer(url: video360)

            } else {
                let item = AVPlayerItem(url: url)
                player = AVPlayer(playerItem: item)

            }
            player?.isMuted = true
            return player
        }
    }

    deinit {
        player = nil
    }
}
