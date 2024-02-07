//
//  VideoPlayerCell.swift
//  HLSVideoReels
//
//  Created by Suresh on 05/01/24.
//

import Foundation
import UIKit
import AVKit
import SDWebImage

final class VideoPlayerCell: UICollectionViewCell {
    private var playerView: VideoPlayerView? = {
        let playerView = VideoPlayerView()
        playerView.translatesAutoresizingMaskIntoConstraints = false
        playerView.contentMode = .scaleAspectFill
        playerView.backgroundColor = .lightGray
        return playerView
    }()
    
    private let progressSlider: UISlider = {
        let slider = UISlider(frame: .zero)
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.setThumbImage(UIImage(), for: .normal)
        slider.minimumTrackTintColor = .white
        slider.maximumTrackTintColor = UIColor(red: 0.8, green: 0.8, blue: 0.851, alpha: 0.3)
        return slider
    }()
    
    private let videoDetailView: VideoDetailView = {
        let view = VideoDetailView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setContentHuggingPriority(.defaultHigh, for: .vertical)
        view.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        return view
    }()
    
    private let videoAssistiveView: VideoAssistiveView = {
        let view = VideoAssistiveView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setContentHuggingPriority(.defaultHigh, for: .vertical)
        view.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        return view
    }()
    
    private var url: URL?
    var shouldShowWidgets = true
    private var pausedTime: CMTime!
    private var isAudioMuted: Bool = false
    var isPlaying: Bool = false
    var isPlayRequested: Bool = false
    private var isPlayedOnce: Bool = false
    private var timeObserver: Any?
    var index: Int = -1
    var reel: Reel? {
        didSet {
            if let reel = reel, let urlString = reel.videoUrl, let url = URL(string: urlString) {
                self.showLoader()
                self.url = url
                videoDetailView.isHidden = false
                videoDetailView.configure(video: reel)
                videoAssistiveView.configure(video: reel)
                
               
            }else {
                self.hideLoader()
                self.url = nil
                videoDetailView.isHidden = true
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        playerView?.isHidden = true
        isPlayedOnce = false
        isPlayRequested = false
        progressSlider.setValue(0, animated: false)
        playerView?.seek(to: CMTime.zero)
        progressSlider.minimumValue = 0
    
    }
    
    private func setupView() {
        
        guard let playerView = playerView else { return }
        contentView.backgroundColor = .white
        contentView.addSubview(playerView)
        setupBottomGradientLayer(playerView: playerView)
        playerView.addSubview(videoDetailView)
        playerView.addSubview(videoAssistiveView)
        playerView.addSubview(progressSlider)
       
        NSLayoutConstraint.activate([
            playerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            playerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            playerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            playerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            videoDetailView.leadingAnchor.constraint(equalTo: playerView.leadingAnchor, constant: 16),
            videoDetailView.trailingAnchor.constraint(equalTo: playerView.trailingAnchor, constant: -16),
            videoDetailView.bottomAnchor.constraint(equalTo: playerView.bottomAnchor, constant: -32),
            
            progressSlider.leadingAnchor.constraint(equalTo: playerView.leadingAnchor),
            progressSlider.topAnchor.constraint(equalTo: videoDetailView.bottomAnchor, constant: 4),
            progressSlider.trailingAnchor.constraint(equalTo: playerView.trailingAnchor),
            
            videoAssistiveView.rightAnchor.constraint(equalTo: playerView.rightAnchor, constant: -4),
            videoAssistiveView.bottomAnchor.constraint(equalTo: videoDetailView.topAnchor, constant: 0),
            videoAssistiveView.widthAnchor.constraint(equalToConstant: VideoAssistiveView.assitiveWidgetSide)
        ])
        
        addTapGesture()
    }
    private func gradient() -> CAGradientLayer {
        let gradient = CAGradientLayer()
        gradient.type = .axial
        gradient.colors = [
            UIColor.black.withAlphaComponent(0.6).cgColor,
            UIColor.clear.cgColor
        ]
        gradient.locations = [0, 1]
        return gradient
    }
    
    private func getNavBarAndSafeAreaHeight() -> CGFloat {
        let window = UIApplication.shared.keyWindow
        let topPadding = window?.safeAreaInsets.top ?? 0
        return 44 + topPadding
    }
    
    private func setupBottomGradientLayer(playerView: VideoPlayerView) {
        var size = contentView.bounds.size
        size.height = getNavBarAndSafeAreaHeight() + 40
        let bottomGradient = gradient()
        bottomGradient.colors?.reverse()
        bottomGradient.frame.origin = CGPoint(x: 0, y: contentView.bounds.height - size.height)
        bottomGradient.frame.size = size
        playerView.layer.addSublayer(bottomGradient)
        playerView.layoutIfNeeded()
    }
    
    func sliderSetup() {
        DispatchQueue.global(qos: .background).async {
            if let duration = self.playerView?.player?.currentItem?.asset.duration as? CMTime {
                let seconds : Float64 = CMTimeGetSeconds(duration)
                DispatchQueue.main.async {
                    let maxValue = Float(seconds)
                    if !maxValue.isNaN, maxValue >= self.progressSlider.minimumValue {
                        self.progressSlider.maximumValue = Float(seconds)
                    }
                }
            }
        }
        progressSlider.isContinuous = true
        progressSlider.minimumValue = 0
        if let totalDuration = playerView?.totalDuration, !totalDuration.isNaN {
            progressSlider.maximumValue = Float(totalDuration)
        }
        progressSlider.addTarget(self, action: #selector(VideoPlayerCell.sliderValueChanged(_:event:)), for: .valueChanged)
    }
    
    private func observeVideoState() {
        playerView?.stateDidChanged = { state in
            switch state {
            case .none:
                print("none")
                self.showLoader()
            case .error(let error):
                print("error - \(error.localizedDescription)")
            case .loading:
                print("loading")
                self.showLoader()
            case .paused(let playing, let buffering):
                print("playing", playing, buffering)
                self.progressSlider.value = playing.float
            case .playing:
                print("playing")
                self.hideLoader()
            case .completed:
                print("completed")
            }
            switch state {
            case .playing, .paused:
                self.progressSlider.isEnabled = true
            default:
                self.progressSlider.isEnabled = false
            }
        }
    }
    
    private func addTapGesture() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapPlayerView(_:)))
        playerView?.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc private func sliderValueChanged(_ sender: UISlider, event: UIEvent) {
        let seconds : Float = Float(sender.value)
        let targetTime:CMTime = CMTimeMake(value: Int64(seconds), timescale: 1)
        playerView?.seek(to: targetTime)
        if let touchEvent = event.allTouches?.first {
            switch touchEvent.phase {
            case .began:
                self.removeTimerObserver()
                self.pause(reason: .waitingKeepUp)
                break
            case .moved:
                // handle drag moved
                break
            case .ended:
                removeTimerObserver()
                playerView?.player?.seek(to: targetTime, toleranceBefore: .zero, toleranceAfter: .zero) { [weak self] (value) in
                    self?.timeObserverSetup()
                    self?.resume()
                }
                break
            default:
                break
            }
        }
    }
    
    @objc private func didTapPlayerView(_ sender: UITapGestureRecognizer) {
        if playerView?.state == .playing {
            pause(reason: .userInteraction)
        } else {
            resume()
        }
    }
    
    private func timeObserverSetup() {
        let interval = CMTime(seconds: 0.2,
                                  preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserver = playerView?.player?.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main, using: { [weak self] elapsedTime in
            DispatchQueue.main.async {
                guard let self = self else {return }
                var currentTime = elapsedTime
//                print("observer \(Float(CMTimeGetSeconds(elapsedTime)))")
                guard self.progressSlider.isTracking == false else { return }
                if self.isPlayRequested == false {
                    currentTime = self.pausedTime
                }
                self.updateSlider(elapsedTime: currentTime)
            }
            
        })
//        print(timeObserver)
    }
    
    func removeTimerObserver() {
        if let timeObserver = self.timeObserver {
            if self.playerView?.player?.isPlaying == false { // it is required as you have to check if player is playing
                self.playerView?.player?.removeTimeObserver(timeObserver)
                print("observer removed")
                self.timeObserver = nil
            }
        }
    }
    
    
    private func updateSlider(elapsedTime: CMTime) {
        let playerDuration = playerItemDuration()
        if CMTIME_IS_INVALID(playerDuration) {
            progressSlider.minimumValue = 0.0
            updatePlayDurationLabel(time: 0.0)
            return
        }
        let duration = Float(CMTimeGetSeconds(playerDuration))
        if duration.isFinite && duration > 0 {
            let time = Float(CMTimeGetSeconds(elapsedTime))
            
            UIView.animate(withDuration: 0.2) {
                self.progressSlider.setValue(time, animated: true)
            }

            updatePlayDurationLabel(time: time)
        }
    }
    
    
    private func playerItemDuration() -> CMTime {
        if let playerItem = playerView?.player?.currentItem {
            if playerItem.status == .readyToPlay {
                return playerItem.duration
            }
        }
        return CMTime.invalid
    }
    
    func pause(reason: VideoPlayerView.PausedReason) {
        isPlayRequested = false
        if let currentTime = playerView?.player?.currentTime() {
            self.pausedTime = currentTime
        }
        self.playerView?.pause(reason: reason)
        
        if reason != .userInteraction {
            self.removeTimerObserver()
        }
    }
    
    func play() {
        isPlayRequested = true
        playerView?.isHidden = false
        if isPlayedOnce {
            playerView?.replay(resetCount: true)
        } else if let url {
            playerView?.play(for: url)
        }
        playerView?.bringSubviewToFront(videoDetailView)
        isPlayedOnce = true
        sliderSetup()
        timeObserverSetup()
        observeVideoState()
    }
    
    func resume() {
        isPlayRequested = true
        playerView?.resume()
    }
    
    func showLoader() {
        isPlaying = false
        //Show - Animate your loader in case anything you have
    }
    
    func hideLoader() {
        isPlaying = true
        //Hide your loader in case anything you have
    }
    
    func resetPlayer() {
        self.removeObserver()
        self.playerView?.player?.replaceCurrentItem(with: nil)
        self.playerView = nil
    }
    
    func removeObserver() {
        self.playerView?.player?.removeTimeObserver(self.timeObserver as Any)
        timeObserver = nil
    }
    
    deinit {
        print("Observer removed")
        removeTimerObserver()
        print("VideoPlayerCell dealloc")
    }
    
    func updatePlayDurationLabel(time: Float) {
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        //Update your play duration label
//        playDurationLabel.text = String(format:"%02i:%02i", minutes, seconds)
    }
    
}



