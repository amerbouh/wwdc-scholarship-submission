import UIKit

public struct Pencil {
    
    public var color: Pencil.Color
    
    public var image: UIImage {
        return UIImage(named: color.rawValue)!
    }
    
    public enum Color: String, CaseIterable {
        case black = "Black"
        case blue = "Blue"
        case brown = "Brown"
        case darkGreen = "DarkGreen"
        case darkOrange = "DarkOrange"
        case grey = "Grey"
        case lightBlue = "LightBlue"
        case lightGreen = "LightGreen"
        case red = "Red"
        case yellow = "Yellow"
    }
    
    // MARK: - Methods
    
    public init(color: Pencil.Color) {
        self.color = color
    }
    
}

extension UIColor {
    
    public static let lightGreen = UIColor(red: 0.20, green: 0.80, blue: 0.40, alpha: 1.0)
    
    public static let darkGreen = UIColor(red: 0.20, green: 0.40, blue: 0.00, alpha: 1.0)
    
    public static let darkOrange = UIColor(red: 1.00, green: 0.40, blue: 0.00, alpha: 1.0)
    
    public static let lightBlue = UIColor(red: 0.20, green: 0.80, blue: 1.00, alpha: 1.0)
    
    public static let darkPurple = UIColor(red: 1.00, green: 0.24, blue: 0.49, alpha: 1.0)
    
}
