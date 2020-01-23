import UIKit
import AVFoundation

public class WelcomeViewController: UIViewController {
    
    private var player: AVAudioPlayer?
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Welcome !"
        
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 34)
        
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        
        // Configure the label...
        label.text = "Tap the Play button to start learning how to write the alphabet's letters !"
        label.numberOfLines = 0
        label.textAlignment = .center
        
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        
        return label
    }()
    
    private let headerContainerStackView: UIStackView = {
        let stackView = UIStackView()
        
        // Configure the stack view...
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .fill
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
    }()
    
    private let playButton: UIButton = {
        let button = UIButton(type: .custom)
        
        // Configure the button...
        let playButtonImage = UIImage(named: "play_button_background")!
        button.setImage(playButtonImage, for: .normal)
        button.contentMode = .scaleAspectFit
        
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    private let blackDimmingLayerView: UIView = {
        let view = UIView()
        
        // Configure the view...
        view.alpha = 0.2
        view.backgroundColor = .black
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private let backgroundImageView: UIImageView = {
        let image = UIImage(named: "background.jpg")
        let imageView = UIImageView(image: image)
        
        // Configure the image view...
        imageView.contentMode = .scaleAspectFill
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()
    
    // MARK: - View's lifecyce
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        configureBackground()
        playBackgroundMusic()
        
        playButton.addTarget(self, action: #selector(showMainViewController), for: .allTouchEvents)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startPlayButtonAnimation()
    }
    
    override public func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        player?.stop()
    }
    
    // MARK: - Methods
    
    private func playBackgroundMusic() {
        guard let backgroundMusicURL = Bundle.main.url(forResource: "background_music", withExtension: "mp3") else { return }
        
        do {
            player = try AVAudioPlayer(contentsOf: backgroundMusicURL)
            
            // Start playing the music.
            player?.prepareToPlay()
            player?.play()
        } catch {
            print("Couldn't load the background music 😖.")
        }
    }
    
    private func startPlayButtonAnimation() {
        playButton.transform = CGAffineTransform(translationX: 0, y: -10)
        
        // Animate the view forever.
        UIView.animate(withDuration: 0.8, delay: 0, options: [UIView.AnimationOptions.autoreverse, UIView.AnimationOptions.repeat, UIView.AnimationOptions.allowUserInteraction], animations: {
            self.playButton.transform = CGAffineTransform.identity
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    @objc
    private func showMainViewController() {
        let presentedVC = UINavigationController(rootViewController: MainViewController())
        navigationController?.present(presentedVC, animated: true, completion: nil)
    }
    
    private func configureBackground() {
        view.addSubview(backgroundImageView)
        view.addSubview(blackDimmingLayerView)
        view.addSubview(headerContainerStackView)
        view.addSubview(playButton)
        
        // Configure the background's constraints.
        backgroundImageView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        backgroundImageView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        backgroundImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        backgroundImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        // Configure the dimming view...
        blackDimmingLayerView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        blackDimmingLayerView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        blackDimmingLayerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        blackDimmingLayerView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        // Configure the header...
        headerContainerStackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 24).isActive = true
        headerContainerStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        headerContainerStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
        
        headerContainerStackView.addArrangedSubview(titleLabel)
        headerContainerStackView.addArrangedSubview(subtitleLabel)
        
        // Configure the play button.
        playButton.heightAnchor.constraint(equalToConstant: 180).isActive = true
        playButton.widthAnchor.constraint(equalToConstant: 180).isActive = true
        playButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        playButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
}
