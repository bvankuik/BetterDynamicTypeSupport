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
    private let bdtsStepperLabel = UILabel()
    
    @objc func bdtsStepperValueChanged(_ sender: BDTSStepper) {
        self.bdtsStepperLabel.text = "\(sender.value)"
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
        topStackView.alignment = .center
        stackView.addArrangedSubview(topStackView)
        
        let bdtsStepper = BDTSStepper()
        bdtsStepper.translatesAutoresizingMaskIntoConstraints = false
        bdtsStepper.addTarget(self, action: #selector(bdtsStepperValueChanged(_:)), for: .valueChanged)
        topStackView.addArrangedSubview(bdtsStepper)
        
        self.bdtsStepperLabel.translatesAutoresizingMaskIntoConstraints = false
        self.bdtsStepperLabel.adjustsFontForContentSizeCategory = true
        self.bdtsStepperLabel.font = .preferredFont(forTextStyle: .body)
        self.bdtsStepperLabel.text = String(describing: bdtsStepper.value)
        self.bdtsStepperLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        topStackView.addArrangedSubview(self.bdtsStepperLabel)
        
        let startTextField = UITextField()
        startTextField.font = .preferredFont(forTextStyle: .body)
        startTextField.adjustsFontForContentSizeCategory = true
        startTextField.placeholder = "Start value"
        stackView.addArrangedSubview(startTextField)
        
        let stepsizeTextField = UITextField()
        stepsizeTextField.font = .preferredFont(forTextStyle: .body)
        stepsizeTextField.adjustsFontForContentSizeCategory = true
        stepsizeTextField.placeholder = "Step size"
        stackView.addArrangedSubview(stepsizeTextField)
        
        let resetButton = UIButton()
        resetButton.setTitle("Reconfigure", for: .normal)
        resetButton.titleLabel?.font = .preferredFont(forTextStyle: .body)
        resetButton.titleLabel?.adjustsFontForContentSizeCategory = true
        stackView.addArrangedSubview(resetButton)
        
        let guide =  self.view.safeAreaLayoutGuide
        let constraints = [
            stackView.topAnchor.constraint(equalTo: guide.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: guide.trailingAnchor),
        ]
        self.view.addConstraints(constraints)
    }
}

