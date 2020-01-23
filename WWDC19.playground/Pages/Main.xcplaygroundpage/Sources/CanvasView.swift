import UIKit
import CoreML
import Vision

private struct Line {
    
    public var color: CGColor
    public var points: [CGPoint]
    
    // MARK: - Methods
    
    init(color: CGColor, points: [CGPoint]) {
        self.color = color
        self.points = points
    }
    
}

public struct PredictionResult {
    
    public var prediction: String?
    public var confidence: VNConfidence?
    
    public var errorMessage: String?

}

public protocol CanvasViewDelegate {
    
    func canvasView(_ canvasView: CanvasView, didReceivePredictionResult result: PredictionResult) -> Void

}

public class CanvasView: UIView {
    
    public var delegate: CanvasViewDelegate?
    
    private var lines: [Line] = []
    private var currentLineColor: CGColor = UIColor.black.cgColor
    
    private var currentGraphicsContext: CGContext?
    
    private lazy var doneButton: UIButton = {
        let button = UIButton()
        
        // Configure the button...
        button.backgroundColor = .darkPurple
        button.layer.cornerRadius = 13
        
        button.setTitle("Submit", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(predict), for: .touchUpInside)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    // MARK: - Methods
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        configureButton()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        // Initialize the current graphics context.
        guard let currentGraphicsContext = UIGraphicsGetCurrentContext() else { return }
    
        // Configure the current graphics context.
        currentGraphicsContext.setLineWidth(5)
        currentGraphicsContext.setLineCap(CGLineCap.round)
        
        // Handle drawing.
        lines.forEach { (line) in
            currentGraphicsContext.setStrokeColor(line.color)
            
            for (index, point) in line.points.enumerated() {
                if index == 0 {
                    currentGraphicsContext.move(to: point)
                } else {
                    currentGraphicsContext.addLine(to: point)
                }
            }

            currentGraphicsContext.strokePath()
        }
    }
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let line = Line(color: currentLineColor, points: [CGPoint]())
        lines.append(line)
        enableDoneButton()
    }
    
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touchCoordinate = touches.first?.location(in: nil),
              var lastLine = lines.popLast() else { return }
        
        lastLine.points.append(touchCoordinate)
        lines.append(lastLine)
        
        setNeedsDisplay()
    }
    
    private func toImage() -> UIImage? {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        let capturedImage = renderer.image(actions: { (context) in
            drawHierarchy(in: bounds, afterScreenUpdates: true)
        })
        
        return capturedImage
    }
    
    private func disableDoneButton() {
        doneButton.isEnabled = false
        doneButton.alpha = 0.5
    }
    
    private func enableDoneButton() {
        doneButton.isEnabled = true
        doneButton.alpha = 1.0
    }
    
    @objc
    private func predict() {
        guard let image = self.toImage()?.toCVPixelBuffer() else { return }
        guard let model = try? VNCoreMLModel(for: LettersClassifier().model) else { return }
        
        // Create the request.
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let observations = request.results as? [VNClassificationObservation],
                  let mostAccurateObservation = observations.first else {
                    let predictionResult = PredictionResult(prediction: nil,
                                                            confidence: nil,
                                                            errorMessage: "Could not make prediction")
                    self.delegate?.canvasView(self, didReceivePredictionResult: predictionResult)
                    return
            }
            
            DispatchQueue.main.async {
                let predictionResult = PredictionResult(prediction: mostAccurateObservation.identifier,
                                                        confidence: mostAccurateObservation.confidence,
                                                        errorMessage: nil)
                self.delegate?.canvasView(self, didReceivePredictionResult: predictionResult)
            }
        }
        
        // Send the request.
        let classifierRequestHandler = VNImageRequestHandler(cvPixelBuffer: image, options: [:])
        do {
            try classifierRequestHandler.perform([request])
        } catch {
            print(error)
        }
    }
    
    public func setLineColor(_ color: Pencil.Color) {
        switch color {
        case .black:
            currentLineColor = UIColor.black.cgColor
            
        case .blue:
            currentLineColor = UIColor.blue.cgColor
            
        case .brown:
            currentLineColor = UIColor.brown.cgColor
            
        case .darkGreen:
            currentLineColor = UIColor.darkGreen.cgColor
            
        case .darkOrange:
            currentLineColor = UIColor.darkOrange.cgColor
            
        case .grey:
            currentLineColor = UIColor.gray.cgColor
            
        case .lightBlue:
            currentLineColor = UIColor.lightBlue.cgColor
            
        case .lightGreen:
            currentLineColor = UIColor.green.cgColor
            
        case .red:
            currentLineColor = UIColor.red.cgColor
            
        case .yellow:
            currentLineColor = UIColor.yellow.cgColor
        }
    }
    
    @objc
    public func clearCanvas() {
        lines.removeAll()
        setNeedsDisplay()
        disableDoneButton()
    }
    
    private func configureButton() {
        addSubview(doneButton)
        
        // Setup done button constraints.
        doneButton.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        doneButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16).isActive = true
        doneButton.heightAnchor.constraint(equalToConstant: 35).isActive = true
        doneButton.widthAnchor.constraint(equalToConstant: 95).isActive = true
        
        // Disable the button.
        disableDoneButton()
    }
   
}
