import UIKit
import AVFoundation

public class InstructionView: UIView {
    
    private var player: AVAudioPlayer?
    private var contentLabel: UILabel = {
        let label = UILabel()
        
        // Configure the view...
        label.textColor = .white
        label.numberOfLines = 0
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    public enum InstructionType {
        case success
        case failure
        case informative
    }
    
    // MARK: - View's lifecycle
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }
    
    // MARK: - Methods
    
    private func configure() {
        backgroundColor = UIColor(red: 0.92, green: 0.53, blue: 0.32, alpha: 1.0)
        layer.cornerRadius = 5
        
        translatesAutoresizingMaskIntoConstraints = false
        
        // Add the content label.
        addSubview(contentLabel)
        
        // Setup the label's constraints.
        contentLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8).isActive = true
        contentLabel.bottomAnchor.constraint(equalToSystemSpacingBelow: bottomAnchor, multiplier: -8)
        contentLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8).isActive = true
        contentLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8).isActive = true
    }
    
    public func show(in view: UIView, withMessage message: String, type: InstructionType = .informative, dismissalHandler: (() -> ())? = nil) {
        view.addSubview(self)
        contentLabel.text = message
        
        // Configure the constraints.
        heightAnchor.constraint(equalToConstant: 95).isActive = true
        leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
        
        let topAnchorConstraint = topAnchor.constraint(equalTo: view.topAnchor, constant: -frame.height)
        topAnchorConstraint.isActive = true
        
        switch type {
            case .success:
                backgroundColor = .lightGreen
            case .failure:
                backgroundColor = .red
            default:
                break
        }
        
        // Animate the appearance of the view.
        UIView.animate(withDuration: 0.5) {
            self.playSoundForInstruction(type)
            topAnchorConstraint.constant = (16 + self.frame.height)
            self.layoutIfNeeded()
        }

        // Remove the instructions after 4 seconds.
        Timer.scheduledTimer(withTimeInterval: 7, repeats: false) { (timer) in
            UIView.animate(withDuration: 0.5, animations: {
                topAnchorConstraint.constant = -(16 + self.frame.height)
                self.layoutIfNeeded()
            }, completion: { (_) in
                self.removeFromSuperview()
                dismissalHandler?()
            })
        }
    }
    
    private func playSoundForInstruction(_ type: InstructionType) {
        var soundURLString: String
        var soundExtensionString: String = "m4a"
        
        switch type {
            case .success:
                soundURLString = "success_sound"
            
            case .failure:
                soundURLString = "error_sound"
            
            case .informative:
                soundURLString = "pop_sound"
                soundExtensionString = "wav"
        }
        
        guard let soundURL = Bundle.main.url(forResource: soundURLString, withExtension: soundExtensionString) else { print("File not found") ; return }
        
        do {
            player = try AVAudioPlayer(contentsOf: soundURL)
            
            // Play the selection sound.
            player!.prepareToPlay()
            player!.play()
        } catch {
            print("Could not play the pencil selection sound.")
        }
    }
    
}

