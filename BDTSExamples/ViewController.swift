//
//  ViewController.swift
//  BDTSExamples
//
//  Created by Bart van Kuik on 03/04/2019.
//  Copyright © 2019 DutchVirtual. All rights reserved.
//

import UIKit
import BetterDynamicTypeSupport

class ViewController: UIViewController {
    private let bdtsStepper = BDTSStepper()
    private let bdtsStepperLabel = UILabel()
    private let startTextField = UITextField()
    private let stopTextField = UITextField()
    private let stepsizeTextField = UITextField()
    
    @objc func bdtsStepperValueChanged(_ sender: BDTSStepper) {
        self.bdtsStepperLabel.text = "\(sender.value)"
    }
    
    @objc func resetStepper() {
        if let text = self.startTextField.text, let value = Double(text) {
            self.bdtsStepper.value = value
            self.bdtsStepper.minimumValue = value
        }
        if let text = self.stopTextField.text, let value = Double(text) {
            self.bdtsStepper.maximumValue = value
        }
        if let text = self.stepsizeTextField.text, let value = Double(text) {
            self.bdtsStepper.stepValue = value
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Views"
        
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 20
        self.view.addSubview(stackView)
        
        let topStackView = UIStackView()
        topStackView.spacing = 20
        stackView.addArrangedSubview(topStackView)
        
        self.bdtsStepper.translatesAutoresizingMaskIntoConstraints = false
        self.bdtsStepper.addTarget(self, action: #selector(bdtsStepperValueChanged(_:)), for: .valueChanged)
        self.bdtsStepper.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        topStackView.addArrangedSubview(self.bdtsStepper)

        self.bdtsStepperLabel.translatesAutoresizingMaskIntoConstraints = false
        self.bdtsStepperLabel.adjustsFontForContentSizeCategory = true
        self.bdtsStepperLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        self.bdtsStepperLabel.font = .preferredFont(forTextStyle: .body)
        self.bdtsStepperLabel.text = String(describing: self.bdtsStepper.value)
        self.bdtsStepperLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        topStackView.addArrangedSubview(self.bdtsStepperLabel)
        topStackView.addArrangedSubview(UIView())

        self.startTextField.borderStyle = .roundedRect
        self.startTextField.font = .preferredFont(forTextStyle: .body)
        self.startTextField.adjustsFontForContentSizeCategory = true
        self.startTextField.placeholder = "Start and minimum value"
        self.startTextField.text = String(describing: self.bdtsStepper.value)
        stackView.addArrangedSubview(self.startTextField)
        
        self.stopTextField.borderStyle = .roundedRect
        self.stopTextField.font = .preferredFont(forTextStyle: .body)
        self.stopTextField.adjustsFontForContentSizeCategory = true
        self.stopTextField.placeholder = "Maximum value"
        self.stopTextField.text = String(describing: self.bdtsStepper.maximumValue)
        stackView.addArrangedSubview(self.stopTextField)
        
        self.stepsizeTextField.borderStyle = .roundedRect
        self.stepsizeTextField.font = .preferredFont(forTextStyle: .body)
        self.stepsizeTextField.adjustsFontForContentSizeCategory = true
        self.stepsizeTextField.placeholder = "Step size"
        self.stepsizeTextField.text = String(describing: self.bdtsStepper.stepValue)
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
    }
}

