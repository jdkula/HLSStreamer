# HLSStreamer
iOS app that allows you to stream your screen over HLS, no external server necessary.

## Building

Clone the repo and open `HLSStreamer.xcodeproj` in Xcode. It will run on iOS devices running iOS/iPadOS 15 or later.

## Usage

While streaming to the app, your iDevice will host a server by default at port `8888`, providing the following endpoints:

- `/`: A simple webpage with a Video.js player that will play back the livestream. This is suitable for use in OBS.
- `/orientation`: Will return the string `up`, `down`, `left`, or `right` depending on the orientation of your iDevice.
    If your iDevice is right-side-up, it will be `up`.
- `/index.m3u8`: The HLS stream playlist. You can open this in VLC or embed it elsewhere and it will play correctly.
- `/video/:file`: The video segments themselves

The UI provides a couple options:
- `Port`: You can adjust what port the server runs on.
- `Segment Duration`: The higher this is, the more reliable the stream, but the longer the delay.
  The default of 1 second is extremely low for use over the internet, but over a local network
  seems to provide reasonable stability and a delay of only about 5 to 7 seconds (in my testing).
  Apple usually recommends 6 seconds, whch leads to a delay of 30-60 seconds.
- `Video Bitrate (Mbps)`: The higher this is, the higher quality the streams but the higher the bandwidth
  they use. In my testing, adjusting this hasn't seemed to do much.

Files are stored in your iDevice's temporary storage and deleted when they leave the HLS sliding window (see below).
They are also cleared when you stop streaming.

## Details

Generates an HLS stream in fMP4 fragments (`header.mp4` and `\(sequenceNumber).m4s`) that are served from the
iDevice in a sliding window lasting approx. 60 seconds. System audio and video are captured, but the user
microphone is not (even if that option is selected while attempting to broadcast to `HLSStreamer`.
