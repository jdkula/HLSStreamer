# HLSStreamer
iOS app that allows you to stream your screen over HLS, no external server or desktop-side applications necessary.

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
- `Video Bitrate (Mbps)`: The higher this is, the higher quality the streams but the higher the bandwidth
  they use. In my testing, adjusting this hasn't seemed to do much.

Files are stored in your iDevice's temporary storage and deleted when they leave the HLS sliding window (see below).
They are also cleared when you stop streaming.

## Details

Generates an HLS stream in fMP4 fragments (`header.mp4` and `\(sequenceNumber).m4s`) that are served from the
iDevice in a sliding window lasting approx. 60 seconds. System audio and video are captured, but the user
microphone is not (even if that option is selected while attempting to broadcast to `HLSStreamer`.

## Demo

Recorded on Chrome, streaming from iPad (stream delay of approx. 5 seconds)


https://user-images.githubusercontent.com/4166625/199675929-ec517b69-efc2-45b9-89e0-a85d95f286e7.mp4


<img alt="Interface screenshot" width="400" src="https://user-images.githubusercontent.com/4166625/199672372-7b14371b-1423-406a-a155-02ff3e72fe76.PNG">
<img alt="Interface screenshot while streaming" width="400" src="https://user-images.githubusercontent.com/4166625/199672383-c2fca114-bb77-45de-be01-d4a36a0c5514.PNG">


## Attributions

The HTTP server is provided by [Swifter](https://github.com/httpswift/swifter)
