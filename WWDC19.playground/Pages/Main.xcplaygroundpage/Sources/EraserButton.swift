import UIKit

public class EraserButton: UIButton {
    
    public init() {
        super.init(frame: .zero)
        prepareForUse()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    
    private func prepareForUse() {
        setImage(UIImage(named: "Eraser"), for: .normal)
        imageView?.contentMode = .scaleAspectFit
    }
    
}
