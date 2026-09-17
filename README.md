# MiniCalm

MiniCalm is a 2-screen iOS application built to demonstrate modern iOS architecture, seamless SwiftUI/UIKit interoperability, and robust media playback using AVFoundation.

## Requirements
1. iOS 16+
2. Xcode 16+
3. Swift 5.9+

## How to Run
1. Clone the repository. 
2. Open `MiniCalm.xcodeproj` in Xcode.
3. Select an iOS Simulator running iOS 16+ or later.
4. Ensure you have an active internet connection.
5. Build and run the project.

*The app fetches meditation session data from the provided JSON endpoint and streams the session audio using AVPlayer.*

## Architecture
The project uses a simple MVVM-style structure:

- SwiftUI is used for the Library screen.
- UIKit + XIB is used for the Player screen.
- ViewModel handles fetching session data from the API.
- NetworkManager handles the URLSession async/await network request.
- Session is the Codable data model.
- AVFoundation / AVPlayer handles audio playback, seeking, playback speed, and background audio.
- UIViewControllerRepresentable is used to bridge the SwiftUI Library screen to the UIKit Player screen.

The Library screen uses redacted placeholder rows while the initial session data is loading.

## Playback
The Player screen supports:
- Play / pause
- Seekable progress slider
- Elapsed and remaining time
- Playback speed: 1x → 1.5x → 2x → 1x
- Audio playback in the background
- Handling unavailable or invalid audio
- Playback completion handling

## What I Would Improve With More Time
If I had more time, I would consider:

- Improving offline behavior and allowing previously downloaded audio to play without a network connection.
- Improving the player state handling for buffering and network interruptions.
- Adding more detailed error states and retry handling.

I intentionally kept the implementation simple and avoided adding unnecessary dependencies or over-engineering the solution.

## AI Assistance
I used AI assistance during development mainly for:

- Discussing implementation approaches and architecture decisions.
- Reviewing Swift/SwiftUI/UIKit code for potential issues.
- Troubleshooting and understanding AVPlayer, seeking, playback speed, and background audio behavior.
- Reviewing edge cases and assignment requirements.

The final implementation was written, tested, and reviewed by me, and I made the implementation decisions based on my understanding of the requirements.
