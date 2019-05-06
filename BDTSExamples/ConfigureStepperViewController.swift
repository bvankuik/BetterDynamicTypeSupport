//
//  ConfigureStepperViewController.swift
//  BDTSExamples
//
//  Created by Bart van Kuik on 06/05/2019.
//  Copyright © 2019 DutchVirtual. All rights reserved.
//

import UIKit
import BetterDynamicTypeSupport

class ConfigureStepperViewController: UIViewController {
    private let startTextField = UITextField()
    private let stopTextField = UITextField()
    private let stepsizeTextField = UITextField()
    private let stepper: BDTSStepper
    private var completion: (() -> Void)?
    
    @objc func resetStepper() {
        if let text = self.startTextField.text, let value = Double(text) {
            self.stepper.value = value
            self.stepper.minimumValue = value
        }
        if let text = self.stopTextField.text, let value = Double(text) {
            self.stepper.maximumValue = value
        }
        if let text = self.stepsizeTextField.text, let value = Double(text) {
            self.stepper.stepValue = value
        }
        self.dismiss(animated: true, completion: self.completion)
    }
    
    @objc func cancel() {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Configure stepper"
        self.view.backgroundColor = .white
        
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 20
        self.view.addSubview(stackView)
        
        let topStackView = UIStackView()
        topStackView.spacing = 20
        stackView.addArrangedSubview(topStackView)
        
        self.startTextField.borderStyle = .roundedRect
        self.startTextField.font = .preferredFont(forTextStyle: .body)
        self.startTextField.adjustsFontForContentSizeCategory = true
        self.startTextField.placeholder = "Start and minimum value"
        stackView.addArrangedSubview(self.startTextField)
        
        self.stopTextField.borderStyle = .roundedRect
        self.stopTextField.font = .preferredFont(forTextStyle: .body)
        self.stopTextField.adjustsFontForContentSizeCategory = true
        self.stopTextField.placeholder = "Maximum value"
        stackView.addArrangedSubview(self.stopTextField)
        
        self.stepsizeTextField.borderStyle = .roundedRect
        self.stepsizeTextField.font = .preferredFont(forTextStyle: .body)
        self.stepsizeTextField.adjustsFontForContentSizeCategory = true
        self.stepsizeTextField.placeholder = "Step size"
        stackView.addArrangedSubview(self.stepsizeTextField)
        
        let resetButton = UIButton()
        resetButton.setTitle("Reconfigure", for: .normal)
        resetButton.titleLabel?.font = .preferredFont(forTextStyle: .body)
        resetButton.titleLabel?.adjustsFontForContentSizeCategory = true
        resetButton.backgroundColor = .blue
        resetButton.addTarget(self, action: #selector(resetStepper), for: .touchUpInside)
        stackView.addArrangedSubview(resetButton)
        
        let guide =  self.view.safeAreaLayoutGuide
        let constraints = [
            stackView.topAnchor.constraint(equalToSystemSpacingBelow: guide.topAnchor, multiplier: 1),
            stackView.leadingAnchor.constraint(equalToSystemSpacingAfter: guide.leadingAnchor, multiplier: 1),
            guide.trailingAnchor.constraint(equalToSystemSpacingAfter: stackView.trailingAnchor, multiplier: 1)
        ]
        self.view.addConstraints(constraints)
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel,
                                                                target: self, action: #selector(cancel))
    }
    
    init(_ stepper: BDTSStepper, completion: (() -> Void)?) {
        self.stepper = stepper
        self.completion = completion
        super.init(nibName: nil, bundle: nil)
        self.startTextField.text = String(describing: stepper.minimumValue)
        self.stopTextField.text = String(describing: stepper.maximumValue)
        self.stepsizeTextField.text = String(describing: stepper.stepValue)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

