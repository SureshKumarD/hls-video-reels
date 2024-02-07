# hls-video-reels

***Reels video app using HTTP Live Streaming(hls) videos(.m3u8)***
Like youtube shorts, instagram reels etc.

## Requirements

| Plugin | README |
| ------ | ------ |
| Language | Swift |
| UI Framework | UIKit |
| WebServer | GCDWebServer |
| Cache | Cache Library |
| Xcode | 15.0.1 |
| Mac OS | 14.1.1 |


### How it works?　

+ A video player view wrapper extended from AVPlayer
+ GCDWebServer is used to host the .m3u8 file url
+ Using the reverse proxy url the contents of .m3u8 file is aggregated and stored locally using the GCDWebServer
+ For local storage, disk storage is being used and it is configured to store upto 200MB
+ Each stored video has 7 days validity


### Prefetching videos
 
```swift
    private var abstractPlayer: AVPlayer?
```
A player instance to start the preload, since it is embedded as a class variable the lifetime of this instance remains until the class/entity persists.


```swift
    func preloadURL(urlArray: [URL]) {
        let player = AVPlayer()
        player.automaticallyWaitsToMinimizeStalling = true
        urlArray.forEach { url in
            guard let videoURL = VideoManager.shared.reverseProxyURL(from: url) else { return }
            let asset = AVURLAsset(url: videoURL)
            let playerItem = AVPlayerItem(asset: asset)
            player.replaceCurrentItem(with: playerItem)
            self.abstractPlayer = player
        }
    }
```
Function to pre-load/pre-fetch multiple videos asynchronously.
 
 
### Offline Caching

Since the videos are cached in disk, for the very first time only it is played from the original url simultaneously the data is downloaded to the local disk storage.
From the very next time the videos are loaded from cache(local disk storage).


### Preview

<img src="HLSVideoReels/Screenshots/1.png?raw=true" width="25%"></img>
<img src="HLSVideoReels/Screenshots/2.png?raw=true" width="25%"></img>
<img src="HLSVideoReels/Screenshots/3.png?raw=true" width="25%"></img>


> Note: Free Software.
> For queries: sureshkumar_durairaj@yahoo.in
