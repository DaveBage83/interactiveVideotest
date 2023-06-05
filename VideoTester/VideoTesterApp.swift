//
//  VideoTesterApp.swift
//  VideoTester
//
//  Created by David Bage on 03/06/2023.
//

import SwiftUI

@main
struct VideoTesterApp: App {
    @State private var videoPlayerEnvironmentObject: VideoPlayerEnvironmentObject = VideoPlayerEnvironmentObject()
    var body: some Scene {
        WindowGroup {
            ContentView(url: URL(string: "https://www.google.com/url?sa=i&url=https%3A%2F%2Funsplash.com%2Fs%2Fphotos%2Ffields&psig=AOvVaw3NbtflBc9jxbb_vAasg_jf&ust=1685863079267000&source=images&cd=vfe&ved=0CBAQjRxqFwoTCPD23cHHpv8CFQAAAAAdAAAAABAE")!, isFullScreenGallery: false)
                .environmentObject(videoPlayerEnvironmentObject)
        }
    }
}
