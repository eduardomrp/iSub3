//
//  PlayerViewController.swift
//  iSub
//
//  Created by Benjamin Baron on 11/15/20.
//  Copyright © 2020 Ben Baron. All rights reserved.
//

import UIKit
import SnapKit

@objc class PlayerViewController: UIViewController {
    var currentSong: Song?
    
    private var notificationObservers = [NSObjectProtocol]()
    
    // Cover Art
    private let coverArtPageControl = PageControlViewController()
    
    // Song info
    private let songInfoContainer = UIView()
    private let songNameLabel = AutoScrollingLabel()
    private let artistNameLabel = AutoScrollingLabel()
    
    // Player controls
    private let controlsStack = UIStackView()
    private let playPauseButton = UIButton(type: .custom)
    private let previousButton = UIButton(type: .custom)
    private let nextButton = UIButton(type: .custom)
    private let quickSkipBackButton = UIButton(type: .custom)
    private let quickSkipForwardButton = UIButton(type: .custom)
    
    // More Controls
    private let moreControlsStack = UIStackView()
    private let repeatButton = UIButton(type: .custom)
    private let equalizerButton = UIButton(type: .custom)
    private let shuffleButton = UIButton(type: .custom)
    
    // Progress bar
    private var progressDisplayLink: CADisplayLink!
    private let progressBarContainer = UIView()
    private let elapsedTimeLabel = UILabel()
    private let remainingTimeLabel = UILabel()
    private let downloadProgressView = UIView()
    private let progressSlider = OBSlider()
    
    // Jukebox
    private let jukeboxVolumeSlider = UISlider()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image:  UIImage(named: "player-overlay"), style: .plain, target: self, action: #selector(showCurrentPlaylist))
        
        //
        // Cover art
        //
        
        view.addSubview(coverArtPageControl.view)
        coverArtPageControl.view.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(40)
            make.leading.equalToSuperview().offset(40).priority(.required)
            make.trailing.equalToSuperview().offset(-40).priority(.required)
            make.height.equalTo(coverArtPageControl.view.snp.width).offset(20)
        }
        
        //
        // Song Info
        //
        
//        songInfoContainer.backgroundColor = .green
        view.addSubview(songInfoContainer)
        songInfoContainer.snp.makeConstraints { make in
            make.width.equalTo(coverArtPageControl.view)
            make.height.equalTo(70)
            make.top.equalTo(coverArtPageControl.view.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }
        
        songNameLabel.font = .boldSystemFont(ofSize: 28)
        songNameLabel.textColor = .label
        songInfoContainer.addSubview(songNameLabel)
        songNameLabel.snp.makeConstraints { make in
            make.height.equalToSuperview().multipliedBy(2.0 / 3.0)
            make.leading.trailing.top.equalTo(songInfoContainer)
        }
        
        artistNameLabel.font = .boldSystemFont(ofSize: 22)
        artistNameLabel.textColor = .secondaryLabel
        songInfoContainer.addSubview(artistNameLabel)
        artistNameLabel.snp.makeConstraints { make in
            make.height.equalToSuperview().multipliedBy(1.0 / 3.0)
            make.leading.trailing.bottom.equalTo(songInfoContainer)
        }
        
        //
        // Progress bar
        //
        
        view.addSubview(progressBarContainer)
        progressBarContainer.snp.makeConstraints { make in
//            make.width.equalTo(songInfoContainer)
            make.height.equalTo(60)
            make.leading.trailing.equalTo(coverArtPageControl.view)
            make.top.equalTo(songInfoContainer.snp.bottom).offset(20)
//            make.centerX.equalToSuperview()
        }

        elapsedTimeLabel.textColor = .label
        elapsedTimeLabel.font = .systemFont(ofSize: 14)
        elapsedTimeLabel.textAlignment = .left
        progressBarContainer.addSubview(elapsedTimeLabel)
        elapsedTimeLabel.snp.makeConstraints { make in
            make.width.equalTo(50)
            make.leading.centerY.equalToSuperview()
        }

        remainingTimeLabel.textColor = .label
        remainingTimeLabel.font = .systemFont(ofSize: 14)
        remainingTimeLabel.textAlignment = .right
        progressBarContainer.addSubview(remainingTimeLabel)
        remainingTimeLabel.snp.makeConstraints { make in
            make.width.equalTo(50)
            make.trailing.centerY.equalToSuperview()
        }

        progressSlider.setThumbImage(UIImage(named: "controller-slider-thumb"), for: .normal)
        progressBarContainer.addSubview(progressSlider)
        progressSlider.snp.makeConstraints { make in
            make.leading.equalTo(elapsedTimeLabel.snp.trailing).offset(10)
            make.trailing.equalTo(remainingTimeLabel.snp.leading).offset(-10)
            make.centerY.equalToSuperview()
        }
        setupProgressSlider()
        
        downloadProgressView.backgroundColor = UIColor.systemGray5.withAlphaComponent(0.7)
        progressBarContainer.insertSubview(downloadProgressView, belowSubview: progressSlider)
        downloadProgressView.snp.makeConstraints { make in
            make.width.equalTo(0)
            make.leading.equalTo(progressSlider).offset(-5)
            make.top.equalTo(progressSlider).offset(-3)
            make.bottom.equalTo(progressSlider).offset(3)
        }
        
        //
        // Controls
        //
        
        controlsStack.axis = .horizontal
        controlsStack.alignment = .center
        controlsStack.distribution = .equalCentering
        controlsStack.addArrangedSubviews([quickSkipBackButton, previousButton, playPauseButton, nextButton, quickSkipForwardButton])
        view.addSubview(controlsStack)
        controlsStack.snp.makeConstraints { make in
            make.height.equalTo(60)
            make.top.equalTo(progressBarContainer.snp.bottom)
//            make.leading.trailing.equalTo(songInfoContainer)
            make.leading.trailing.equalTo(coverArtPageControl.view)
        }
        
        playPauseButton.setImage(UIImage(named: "controller-play"), for: .normal)
        playPauseButton.addClosure(for: .touchUpInside) { [unowned self] in
            if Settings.shared().isJukeboxEnabled {
                if Jukebox.shared().isPlaying {
                    Jukebox.shared().stop()
                } else {
                    Jukebox.shared().play()
                }
            } else {
                if let player = AudioEngine.shared().player, let currentSong = self.currentSong, !currentSong.isVideo {
                    // If we're already playing, toggle the player state
                    player.playPause()
                } else {
                    // If we haven't started the song yet, start the player
                    Music.shared().playSong(atPosition: PlayQueue.shared().currentIndex)
                }
            }
        }
        
        previousButton.setImage(UIImage(named: "controller-previous"), for: .normal)
        previousButton.addClosure(for: .touchUpInside) {
            if let player = AudioEngine.shared().player, player.progress > 10.0 {
                // If we're more than 10 seconds into the song, restart it
                Music.shared().playSong(atPosition: PlayQueue.shared().currentIndex)
            } else {
                // Otherwise, go to the previous song
                Music.shared().prevSong()
            }
        }
        
        nextButton.setImage(UIImage(named: "controller-next"), for: .normal)
        nextButton.addClosure(for: .touchUpInside) {
            Music.shared().nextSong()
        }
        
        let seconds = Settings.shared().quickSkipNumberOfSeconds
        let quickSkipTitle = seconds < 60 ? "\(seconds)s" : "\(seconds/60)m"

        quickSkipBackButton.setBackgroundImage(UIImage(named: "controller-back30"), for: .normal)
        quickSkipBackButton.setTitle(quickSkipTitle, for: .normal)
        quickSkipBackButton.setTitleColor(.darkGray, for: .normal)
        quickSkipBackButton.titleLabel?.font = .systemFont(ofSize: 8)
        quickSkipBackButton.titleEdgeInsets.left = 6
        quickSkipBackButton.addClosure(for: .touchUpInside) { [unowned self] in
            let value = self.progressSlider.value - Float(Settings.shared().quickSkipNumberOfSeconds);
            self.progressSlider.value = value > 0.0 ? value : 0.0;
            seekedAction()
            Flurry.logEvent("QuickSkip")
        }
        
        quickSkipForwardButton.setBackgroundImage(UIImage(named: "controller-forw30"), for: .normal)
        quickSkipForwardButton.setTitle(quickSkipTitle, for: .normal)
        quickSkipForwardButton.setTitleColor(.darkGray, for: .normal)
        quickSkipForwardButton.titleLabel?.font = .systemFont(ofSize: 8)
        quickSkipForwardButton.titleEdgeInsets.right = 6
        quickSkipForwardButton.addClosure(for: .touchUpInside) { [unowned self] in
            let value = self.progressSlider.value + Float(Settings.shared().quickSkipNumberOfSeconds)
            if value >= self.progressSlider.maximumValue {
                Music.shared().nextSong()
            } else {
                self.progressSlider.value = value
                seekedAction()
                Flurry.logEvent("QuickSkip")
            }
        }
        
        //
        // More Controls
        //
        
        moreControlsStack.axis = .horizontal
        moreControlsStack.alignment = .center
        moreControlsStack.distribution = .equalCentering
        moreControlsStack.addArrangedSubviews([repeatButton, equalizerButton, shuffleButton])
        view.addSubview(moreControlsStack)
        moreControlsStack.snp.makeConstraints { make in
            make.height.equalTo(60)
            make.top.equalTo(controlsStack.snp.bottom)
            make.leading.trailing.equalTo(coverArtPageControl.view)
        }
        
        updateRepeatButtonIcon()
        repeatButton.addClosure(for: .touchUpInside) { [unowned self] in
            switch PlayQueue.shared().repeatMode {
            case ISMSRepeatMode_Normal: PlayQueue.shared().repeatMode = ISMSRepeatMode_RepeatOne
            case ISMSRepeatMode_RepeatOne: PlayQueue.shared().repeatMode = ISMSRepeatMode_RepeatAll
            case ISMSRepeatMode_RepeatAll: PlayQueue.shared().repeatMode = ISMSRepeatMode_Normal
            default: break
            }
            self.updateRepeatButtonIcon()
        }
        
        let equalizerButtonConfig = UIImage.SymbolConfiguration(pointSize: 24, weight: .regular, scale: .large)
        equalizerButton.setImage(UIImage(systemName: "slider.vertical.3", withConfiguration: equalizerButtonConfig), for: .normal)
        equalizerButton.addClosure(for: .touchUpInside) { [unowned self] in
            let controller = EqualizerViewController(nibName: "EqualizerViewController", bundle: nil)
            self.navigationController?.pushViewController(controller, animated: true)
        }
        updateEqualizerButton()
        
        updateShuffleButtonIcon()
        shuffleButton.addClosure(for: .touchUpInside) { [unowned self] in
            let message = PlayQueue.shared().isShuffle ? "Unshuffling" : "Shuffling"
            ViewObjects.shared().showLoadingScreenOnMainWindow(withMessage: message)
            EX2Dispatch.runInBackgroundAsync {
                PlayQueue.shared().shuffleToggle()
            }
            self.updateShuffleButtonIcon()
        }
        
        //
        // Jukebox
        //
        
        jukeboxVolumeSlider.setThumbImage(UIImage(named: "controller-slider-thumb"), for: .normal)
        jukeboxVolumeSlider.minimumValue = 0.0
        jukeboxVolumeSlider.maximumValue = 1.0
        jukeboxVolumeSlider.isContinuous = false
        jukeboxVolumeSlider.addClosure(for: .valueChanged) { [unowned self] in
            Jukebox.shared().setVolume(self.jukeboxVolumeSlider.value)
        }
        updateJukeboxControls()
        
//        remakeConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateSongInfo()
        startUpdatingSlider()
        startUpdatingDownloadProgress()
        updateJukeboxControls()
        updateEqualizerButton()
        registerForNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopUpdatingSlider()
        stopUpdatingDownloadProgress()
        unregisterForNotifications()
    }
    
//    private func remakeConstraints() {
//        if UIApplication.orientation().isPortrait {
//            coverArt.snp.makeConstraints { make in
//                make.width.equalTo(coverArt.height)
//                make.top.leading.trailing.equalToSuperview().offset(20)
//            }
//        }
//    }
    
    private func registerForNotifications() {
        NotificationCenter.addObserverOnMainThread(self, selector: #selector(updateSongInfo), name: ISMSNotification_JukeboxSongInfo)
        NotificationCenter.addObserverOnMainThread(self, selector: #selector(updateSongInfo), name: ISMSNotification_CurrentPlaylistIndexChanged)
        NotificationCenter.addObserverOnMainThread(self, selector: #selector(updateSongInfo), name: ISMSNotification_ServerSwitched)
        NotificationCenter.addObserverOnMainThread(self, selector: #selector(updateSongInfo), name: ISMSNotification_CurrentPlaylistShuffleToggled)
        NotificationCenter.addObserverOnMainThread(self, selector: #selector(updateSongInfo), name: ISMSNotification_ShowPlayer)
        
        NotificationCenter.addObserverOnMainThread(self, selector: #selector(updateJukeboxControls), name: ISMSNotification_JukeboxDisabled)
        NotificationCenter.addObserverOnMainThread(self, selector: #selector(updateJukeboxControls), name: ISMSNotification_JukeboxEnabled)
        
        notificationObservers.append(NotificationCenter.addObserverOnMainThreadForName(ISMSNotification_SongPlaybackEnded) { [unowned self] _ in
            self.playPauseButton.setImage(UIImage(named: "controller-play"), for: .normal)
        })
        notificationObservers.append(NotificationCenter.addObserverOnMainThreadForName(ISMSNotification_SongPlaybackPaused, object: nil) { [unowned self] _ in
            self.playPauseButton.setImage(UIImage(named: "controller-play"), for: .normal)
        })
        notificationObservers.append(NotificationCenter.addObserverOnMainThreadForName(ISMSNotification_SongPlaybackStarted, object: nil) { [unowned self] _ in
            self.playPauseButton.setImage(UIImage(named: "controller-pause"), for: .normal)
        })
        
        notificationObservers.append(NotificationCenter.addObserverOnMainThreadForName(ISMSNotification_CurrentPlaylistShuffleToggled) { [unowned self] _ in
            self.updateShuffleButtonIcon()
            self.updateSongInfo()
            ViewObjects.shared().hideLoadingScreen()
        })
    }
    
    private func unregisterForNotifications() {
        NotificationCenter.removeObserverOnMainThread(self)
        for observer in notificationObservers {
            NotificationCenter.removeObserverOnMainThread(observer)
        }
    }
    
    deinit {
        unregisterForNotifications()
    }
    
    private func startUpdatingSlider() {
        guard progressDisplayLink == nil else {
            progressDisplayLink.isPaused = false
            return
        }
        
        progressDisplayLink = CADisplayLink(target: self, selector: #selector(updateSlider))
        progressDisplayLink.isPaused = false
        progressDisplayLink.add(to: .main, forMode: .default)
    }
    
    private func stopUpdatingSlider() {
        guard progressDisplayLink != nil else { return }
        
        progressDisplayLink.isPaused = true
        progressDisplayLink.remove(from: .main, forMode: .default)
        progressDisplayLink = nil
    }
    
    private func setupProgressSlider() {
        // Started seeking
        progressSlider.addClosure(for: .touchDown) { [unowned self] in
            print("slider touch down")
            self.progressDisplayLink.isPaused = true
        }
        
        // During seeking
        progressSlider.addClosure(for: .valueChanged) { //[unowned self] in
            print("slider value changed")
        }

        // End Seeking
        progressSlider.addTarget(self, action: #selector(seekedAction), for: .touchUpInside)
        progressSlider.addTarget(self, action: #selector(seekedAction), for: .touchUpOutside)
        progressSlider.addTarget(self, action: #selector(seekedAction), for: .touchCancel)
    }
    
    @objc private func seekedAction() {
        guard let currentSong = currentSong, let player = AudioEngine.shared().player else {
            self.progressDisplayLink.isPaused = false
            return
        }
        
        // TOOD: Why is this multipled by 128?
        let byteOffset = BassWrapper.estimateBitrate(player.currentStream) * 128 * UInt(progressSlider.value)
        if currentSong.isTempCached {
            player.stop()
            
            AudioEngine.shared().startByteOffset = byteOffset
            AudioEngine.shared().startSecondsOffset = UInt(progressSlider.value)
            
            StreamManager.shared().removeStream(at: 0)
            StreamManager.shared().queueStream(for: currentSong, isTempCache: true, isStartDownload: true)
            if StreamManager.shared().handlerStack.count > 1 {
                if let handler = StreamManager.shared().handlerStack.firstObject as? ISMSStreamHandler {
                    handler.start()
                }
            }
            self.progressDisplayLink.isPaused = false
        } else {
            if currentSong.isFullyCached || byteOffset < currentSong.localFileSize {
                player.seekToPosition(inSeconds: Double(progressSlider.value), fadeVolume: true)
                self.progressDisplayLink.isPaused = false
            } else {
                let message = "You are trying to skip further than the song has cached. You can do this, but the song won't be cached. Or you can wait a little bit for the cache to catch up."
                let alert = UIAlertController(title: "Past Cache Point", message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                    player.stop()
                    AudioEngine.shared().startByteOffset = byteOffset
                    AudioEngine.shared().startSecondsOffset = UInt(self.progressSlider.value)
                    
                    StreamManager.shared().removeStream(at: 0)
                    StreamManager.shared().queueStream(for: currentSong, byteOffset: UInt64(byteOffset), secondsOffset: Double(self.progressSlider.value), at: 0, isTempCache: true, isStartDownload: true)
                    if StreamManager.shared().handlerStack.count > 1 {
                        if let handler = StreamManager.shared().handlerStack.firstObject as? ISMSStreamHandler {
                            handler.start()
                        }
                    }
                    self.progressDisplayLink.isPaused = false
                })
                alert.addAction(UIAlertAction(title: "Wait", style: .cancel) { _ in
                    self.progressDisplayLink.isPaused = false
                })
            }
        }
    }
    
    @objc private func updateSlider() {
        guard let currentSong = currentSong, let player = AudioEngine.shared().player else { return }
//        print("\(Date().timeIntervalSince1970)update slider called")
        
        let duration = currentSong.duration?.doubleValue ?? 0.0
        if Settings.shared().isJukeboxEnabled {
            elapsedTimeLabel.text = NSString.formatTime(0)
            remainingTimeLabel.text = "-\(NSString.formatTime(duration) ?? "0:00")"
            progressSlider.value = 0.0;
        } else {
            elapsedTimeLabel.text = NSString.formatTime(player.progress)
            remainingTimeLabel.text = "-\(NSString.formatTime(player.progress - duration) ?? "0:00")"
            progressSlider.value = Float(player.progress)
        }
    }
    
    @objc private func updateSongInfo() {
        guard let song = PlayQueue.shared().currentSong() else {
            currentSong = nil
            coverArtPageControl.coverArtId = nil
            coverArtPageControl.coverArtImage = UIImage(named: "default-album-art-ipad")
            songNameLabel.text = nil
            artistNameLabel.text = nil
            progressSlider.value = 0
            return
        }
        
        currentSong = song
        coverArtPageControl.coverArtId = song.coverArtId
        songNameLabel.text = song.title
        artistNameLabel.text = song.artist
        progressSlider.maximumValue = song.duration?.floatValue ?? 0.0
    }
    
    @objc private func startUpdatingDownloadProgress() {
        stopUpdatingDownloadProgress()
        guard let currentSong = currentSong, !currentSong.isTempCached else {
            downloadProgressView.isHidden = true
            perform(#selector(startUpdatingDownloadProgress), with: nil, afterDelay: 1.0)
            return
        }
        
        downloadProgressView.isHidden = false
        
        // Set the width based on the download progress + leading offset size
        let width = (currentSong.downloadProgress * progressSlider.frame.width) + 5
        
        if width > downloadProgressView.frame.width {
            // If it's longer, animate it
            UIView.animate(withDuration: 1.0) {
                self.downloadProgressView.snp.updateConstraints { make in
                    make.width.equalTo(width)
                }
                self.downloadProgressView.layoutIfNeeded()
            }
        } else {
            // If it's shorter, it's probably starting a new song so don't animate
            self.downloadProgressView.snp.updateConstraints { make in
                make.width.equalTo(width)
            }
            self.downloadProgressView.layoutIfNeeded()
        }
        
        perform(#selector(startUpdatingDownloadProgress), with: nil, afterDelay: 1.0)
    }
    
    private func stopUpdatingDownloadProgress() {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(startUpdatingDownloadProgress), object: nil)
    }
    
    @objc private func showCurrentPlaylist() {
//        let controller = CurrentPlaylistBackgroundViewController(nibName: "CurrentPlaylistBackgroundViewController", bundle: nil)
        let controller = CurrentPlaylistViewController()
        present(controller, animated: true, completion: nil)
    }
    
    private func updateRepeatButtonIcon() {
        let imageName: String
        switch PlayQueue.shared().repeatMode {
        case ISMSRepeatMode_RepeatOne: imageName = "controller-repeat-one"
        case ISMSRepeatMode_RepeatAll: imageName = "controller-repeat-all"
        default: imageName = "controller-repeat"
        }
        
        repeatButton.setImage(UIImage(named: imageName), for: .normal)
    }
    
    private func updateShuffleButtonIcon() {
        let imageName = PlayQueue.shared().isShuffle ? "controller-shuffle-on" : "controller-shuffle"
        shuffleButton.setImage(UIImage(named: imageName), for: .normal)
    }
    
    @objc private func updateJukeboxControls() {
        if Settings.shared().isJukeboxEnabled && jukeboxVolumeSlider.superview == nil {
            // Add the volume control
            jukeboxVolumeSlider.value = Jukebox.shared().gain
            view.addSubview(jukeboxVolumeSlider)
            jukeboxVolumeSlider.snp.remakeConstraints { make in
                make.leading.trailing.equalTo(moreControlsStack)
                make.leading.trailing.equalTo(coverArtPageControl.view)
//                make.width.equalTo(200)
//                make.centerX.equalToSuperview()
                make.top.equalTo(moreControlsStack.snp.bottom).offset(30)
            }
        } else if !Settings.shared().isJukeboxEnabled && jukeboxVolumeSlider.superview != nil {
            // Remove the volume control
            jukeboxVolumeSlider.removeFromSuperview()
        }
    }
    
    private func updateEqualizerButton() {
        equalizerButton.tintColor = Settings.shared().isEqualizerOn ? .systemBlue : UIColor(white: 0.8, alpha: 1.0)
    }
}

