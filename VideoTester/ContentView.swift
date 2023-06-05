//
//  ContentView.swift
//  VideoTester
//
//  Created by David Bage on 03/06/2023.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var videoPlayerEnvironmentObject: VideoPlayerEnvironmentObject

    @State var shouldPlayVideo: Bool
    @State var didLoadVideo: Bool = false
    @State var didError: Bool = false
    @State var didFinishPlayingVideo: Bool = false
    @State var sliderValue = 0.5
    @StateObject private var deviceRollReader = DeviceRollReader(inputRange: -.pi / 5 ... .pi / 5)
    
    let url: URL
    let isFullScreenGallery: Bool
    
    init(url: URL, isFullScreenGallery: Bool) {
        self.url = url
        self.isFullScreenGallery = isFullScreenGallery
        self._shouldPlayVideo = State(initialValue: true)
    }
    
    var body: some View {
        VStack {
            Text("Video test")
            VideoPlayerViewRepresentable(shouldPlayVideo: $shouldPlayVideo,
                                         didError: $didError,
                                         didFinishPlayingVideo: $didFinishPlayingVideo,
                                         moveTo: $sliderValue,
                                         videoURL: url,
                                         backgroundColour: isFullScreenGallery ? .black : .white,
                                         isFullScreenGallery: isFullScreenGallery)
            .frame(height: 300)
            .environmentObject(videoPlayerEnvironmentObject)
            .onAppear {
                deviceRollReader.startReading()
            }
            .onDisappear {
                deviceRollReader.stopReading()
            }
            .onChange(of: deviceRollReader.roll, perform: { newValue in
                onRollChange(roll: newValue)
            })
        }
    }
    
    @State var previousRoll: Double = 0.0

    private func onRollChange(roll: Double) {
            let directionThreshold: Double = 0.1 // Adjust this value as needed

            if roll > previousRoll + directionThreshold {
                // Roll change indicates a move to the right
                sliderValue += 0.1 // Adjust the increment value as needed
            } else if roll < previousRoll - directionThreshold {
                // Roll change indicates a move to the left
                sliderValue -= 0.1 // Adjust the decrement value as needed
            }

            previousRoll = roll // Update the previous roll value
        }

}
