import UIKit
import AVFoundation

public class PencilButton: UIButton {
    
    private var pencil: Pencil
    private var player: AVAudioPlayer?
    
    public var pencilColor: Pencil.Color {
        return pencil.color
    }
    
    // MARK: - Methods
    
    public init(pencil: Pencil) {
        self.pencil = pencil
        super.init(frame: .zero)
        
        // Configure the button.
        configureWithPencil(pencil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureWithPencil(_ pencil: Pencil) {
        setImage(pencil.image, for: .normal)
        imageView?.contentMode = .scaleAspectFit
    }
    
    public func playSelectionSound() {
        guard let soundURL = Bundle.main.url(forResource: "pencil_selection_sound", withExtension: "m4a") else { print("File not found") ; return }
        
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
