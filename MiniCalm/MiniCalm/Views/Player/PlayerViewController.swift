import UIKit
import AVFoundation

class PlayerViewController: UIViewController {

    //MARK: - Outlets
    @IBOutlet weak var artworkImageView     : UIImageView!
    @IBOutlet weak var titleLabel           : UILabel!
    @IBOutlet weak var teacherLabel         : UILabel!
    @IBOutlet weak var progressSlider       : UISlider!
    @IBOutlet weak var elapsedTimeLabel     : UILabel!
    @IBOutlet weak var remainingTimeLabel   : UILabel!
    @IBOutlet weak var playPauseButton      : UIButton!
    @IBOutlet weak var speedButton          : UIButton!

    //MARK: - Variables
    var session                             : Session?
    private var player                      : AVPlayer?
    private var timeObserverToken           : Any?
    private var statusObservation           : NSKeyValueObservation?
    private let speeds                      : [Float] = [1.0, 1.5, 2.0]
    private var currentSpeedIndex           = 0
    private var wasPlayingBeforeScrubbing   = false

    //MARK: - Life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupAudioSession()
        setupPlayer()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.isMovingFromParent {
            player?.pause()
            removeTimeObserver()
            statusObservation?.invalidate()
            statusObservation = nil
        }
    }

    //MARK: - User defined methods
    private func setupUI() {
        titleLabel.text = session?.title ?? "Unknown Session"
        teacherLabel.text = session?.teacher ?? "Unknown Teacher"
        
        if let artworkUrlString = session?.artwork_url, let url = URL(string: artworkUrlString) {
            URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.artworkImageView.image = image
                    }
                }
            }.resume()
        }
        
        playPauseButton.layer.cornerRadius = playPauseButton.frame.height / 2
        speedButton.setTitle("1x", for: .normal)
        
        // Add specific touch events for smooth slider scrubbing
        progressSlider.addTarget(self, action: #selector(sliderTouchDown(_:)), for: .touchDown)
        progressSlider.addTarget(self, action: #selector(sliderTouchUp(_:)), for: [.touchUpInside, .touchUpOutside])
    }

    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set audio session category: \(error)")
        }
    }

    private func setupPlayer() {
        guard let urlString = session?.audio_url, let url = URL(string: urlString) else {
            // Handling missing audio URL
            handleAudioFailure()
            return
        }
        
        let playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)
        
        // Observe if the audio URL is broken (e.g. 404 Not Found)
        statusObservation = playerItem.observe(\.status, options: [.new]) { [weak self] item, _ in
            DispatchQueue.main.async {
                if item.status == .failed {
                    self?.handleAudioFailure()
                }
            }
        }
        
        addTimeObserver()
        
        player?.play()
        playPauseButton.setTitle("", for: .normal)
        playPauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        
        applyCurrentSpeed()
    }
    
    private func handleAudioFailure() {
        // Disabling controls since there's no audio
        playPauseButton.isEnabled = false
        speedButton.isEnabled = false
        progressSlider.isEnabled = false
        playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        
        let alert = UIAlertController(
            title: "Audio Unavailable",
            message: "We're sorry, but the audio file for this session is missing or broken.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true)
    }

    private func addTimeObserver() {
        let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserverToken = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            self?.updateSliderAndLabels(currentTime: time)
        }
    }

    private func removeTimeObserver() {
        if let token = timeObserverToken {
            player?.removeTimeObserver(token)
            timeObserverToken = nil
        }
    }

    private func updateSliderAndLabels(currentTime: CMTime) {
        guard let currentItem = player?.currentItem,
              currentItem.status == .readyToPlay else { return }
        
        let duration = currentItem.duration
        guard duration.isNumeric else { return }
        
        let totalSeconds = CMTimeGetSeconds(duration)
        let currentSeconds = CMTimeGetSeconds(currentTime)
        
        if !progressSlider.isTracking {
            if totalSeconds > 0 {
                progressSlider.value = Float(currentSeconds / totalSeconds)
            }
            elapsedTimeLabel.text = formatTime(seconds: currentSeconds)
            remainingTimeLabel.text = "-" + formatTime(seconds: totalSeconds - currentSeconds)
        }
    }

    private func formatTime(seconds: Float64) -> String {
        guard !seconds.isNaN && !seconds.isInfinite else { return "0:00" }
        let totalSeconds = Int(seconds)
        let minutes = totalSeconds / 60
        let remainder = totalSeconds % 60
        return String(format: "%d:%02d", minutes, remainder)
    }
    
    private func applyCurrentSpeed() {
        let rate = speeds[currentSpeedIndex]
        if player?.rate != 0 {
            player?.rate = rate
        }
        speedButton.setTitle("\(rate)x", for: .normal)
    }

    // MARK: - Button Actions
    @IBAction func playPauseTapped(_ sender: UIButton) {
        if player?.rate == 0 {
            player?.play()
            applyCurrentSpeed()
            playPauseButton.setTitle("", for: .normal)
            playPauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        } else {
            player?.pause()
            playPauseButton.setTitle("", for: .normal)
            playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        }
    }

    @IBAction func speedTapped(_ sender: UIButton) {
        currentSpeedIndex = (currentSpeedIndex + 1) % speeds.count
        applyCurrentSpeed()
    }

    @IBAction func sliderValueChanged(_ sender: UISlider) {
        guard let duration = player?.currentItem?.duration, duration.isNumeric else { return }
        let totalSeconds = CMTimeGetSeconds(duration)
        let currentSeconds = Float64(sender.value) * totalSeconds
        
        elapsedTimeLabel.text = formatTime(seconds: currentSeconds)
        remainingTimeLabel.text = "-" + formatTime(seconds: totalSeconds - currentSeconds)
        
    }
    
    // MARK: - Custom Slider Scrubbing Logic
    
    @objc private func sliderTouchDown(_ sender: UISlider) {
        wasPlayingBeforeScrubbing = (player?.rate != 0)
        player?.pause()
    }

    @objc private func sliderTouchUp(_ sender: UISlider) {
        guard let duration = player?.currentItem?.duration, duration.isNumeric else { return }
        
        let totalSeconds = CMTimeGetSeconds(duration)
        let targetTime = CMTime(seconds: Float64(sender.value) * totalSeconds, preferredTimescale: 1000)
        
        player?.seek(to: targetTime, toleranceBefore: .zero, toleranceAfter: .zero) { [weak self] _ in
            if self?.wasPlayingBeforeScrubbing == true {
                self?.player?.play()
                self?.applyCurrentSpeed()
            }
        }
    }
}
