import UIKit
import CoreML
import Vision
import AVFoundation

public class MainViewController: UIViewController {
    
    private var player: AVAudioPlayer?
    private var requests: [VNRequest] = []
    private var lastSelectedPencil: PencilButton?
    
    private var currentLetter: String = "A"
    private var lettersList: [String] = [
        "A",
        "B",
        "C",
        "D",
        "E"
    ]
    
    private lazy var clearBarButtonItem: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(image: UIImage(named: "ic_waste"), style: .plain, target: self, action: #selector(handleCanvasReset))
        return barButtonItem
    }()
    
    private lazy var canvasView: CanvasView = {
        let view = CanvasView()
        
        // Configure the view...
        view.delegate = self
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private let pencilCaseStackView: UIStackView = {
        let stackView = UIStackView()
        
        // Configure the stack view...
        stackView.axis = .horizontal
        stackView.spacing = 0
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
    }()
    
    private lazy var pencilCaseContainerView: UIView = {
        let view = UIView()
        
        // Configure the view...
        view.layer.cornerRadius = 6
        view.backgroundColor = UIColor(red:0.55, green:0.53, blue:0.82, alpha:1.0)
        
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowRadius = view.layer.cornerRadius
        view.layer.shadowOffset = CGSize(width: 0, height: 10)
        view.layer.shadowOpacity = 1
        
        // Configure the pencil case stack view.
        view.addSubview(pencilCaseStackView)
        
        pencilCaseStackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 5).isActive = true
        pencilCaseStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        pencilCaseStackView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        pencilCaseStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        pencilCaseStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
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
    
    private var lastPoint: CGPoint?
    
    // MARK: - View's lifecycle
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        configurationNavigationBar()
        prepareCanvasForDrawing()
        showInstructionsView(forLetter: currentLetter)
    }

    // MARK: - Methods
    
    private func configurationNavigationBar() {
        edgesForExtendedLayout = []
        
        navigationItem.title = "Canvas"
        navigationItem.leftBarButtonItem = clearBarButtonItem
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.barTintColor = UIColor(red: 0.55, green:0.53, blue: 0.82, alpha: 1.0)
        navigationController?.navigationBar.isTranslucent = false
        
    }
    
    private func prepareCanvasForDrawing() {
        view.addSubview(backgroundImageView)
        view.addSubview(canvasView)
        view.addSubview(pencilCaseContainerView)
        
        backgroundImageView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        backgroundImageView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        backgroundImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        backgroundImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        // Configure the pencil case's constraints.
        pencilCaseContainerView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        pencilCaseContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 5).isActive = true
        pencilCaseContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        pencilCaseContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
        
        // Configure the canvas' constraints.
        canvasView.backgroundColor = .white
        
        canvasView.topAnchor.constraint(equalTo: view.topAnchor, constant: 16).isActive = true
        canvasView.bottomAnchor.constraint(equalTo: pencilCaseContainerView.topAnchor, constant: -16).isActive = true
        canvasView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        canvasView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
        
        // Add every pencil to the pencil case.
        Pencil.Color.allCases.forEach { (pencilColor) in
            let pencil = Pencil(color: pencilColor)
            let pencilButton = PencilButton(pencil: pencil)
            
            pencilButton.addTarget(self, action: #selector(handlePencilSelection(_:)), for: .touchUpInside)
            pencilCaseStackView.addArrangedSubview(pencilButton)
        }
    }
    
    @objc
    private func showInstructionsView(forLetter letter: String) {
        let instructionsView = InstructionView()
        instructionsView.show(in: canvasView, withMessage: "Pick a color of your choice and write the letter \(letter) ! When you are done, your virtual teacher will give you a feedback 😀.")
    }
    
    @objc
    private func handleCanvasReset() {
        canvasView.clearCanvas()
    }
    
    @objc
    private func handlePencilSelection(_ pencil: PencilButton) {
        if let lastSelectedPencil = self.lastSelectedPencil, lastSelectedPencil != pencil  {
            UIView.animate(withDuration: 0.05) {
                pencil.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
                lastSelectedPencil.transform = CGAffineTransform.identity
                
                self.view.layoutIfNeeded()
            }
        } else if lastSelectedPencil == nil {
            UIView.animate(withDuration: 0.05) {
                pencil.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
                self.view.layoutIfNeeded()
            }
        }
        
        pencil.playSelectionSound()
        
        // Update the last selected cell
        lastSelectedPencil = pencil
        canvasView.setLineColor(lastSelectedPencil!.pencilColor)
    }
    
}

extension MainViewController: CanvasViewDelegate {
    
    public func canvasView(_ canvasView: CanvasView, didReceivePredictionResult result: PredictionResult) {
        if let _ = result.errorMessage {
            let alertController = UIAlertController(title: "Oops",
                                                    message: "An error occured while trying to correct your answer ! Please try again.",
                                                    preferredStyle: .alert)
            present(alertController, animated: true, completion: nil)
        } else {
            let predictedLetter = result.prediction!
            let confidence = result.confidence!
            let alertView = InstructionView()
            
            if confidence > 0.9 && predictedLetter == currentLetter {
                alertView.show(in: canvasView, withMessage: "Congrats, you juste wrote the letter \(currentLetter) correctly ! Now you can jump to the next step and learn how to write a new letter", type: .success, dismissalHandler: {
                    if let currentIndex = self.lettersList.firstIndex(of: self.currentLetter) {
                        if currentIndex == (self.lettersList.count - 1) {
                            let alertView = InstructionView()
                            alertView.show(in: self.canvasView, withMessage: "Congrats, you were able to write correctly every letter of the demonstration ! Hope to see you at WWDC !")
                        } else {
                            self.lettersList.enumerated().forEach({ (index, letter) in
                                if index == (currentIndex + 1) {
                                    self.currentLetter = letter
                                }
                            })
                            
                            self.showInstructionsView(forLetter: self.currentLetter)
                        }
                    }
                })
            } else {
                alertView.show(in: canvasView, withMessage: "Looks like you did not write the letter correctlly ! No problem, you can click on the bin to reset the canvas and try again.", type: .failure)
            }
            
            print("Predicted letter \(predictedLetter) with \(confidence * 100)% of confidence")
        }
    }
    
}
