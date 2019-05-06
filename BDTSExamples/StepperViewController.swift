//
//  ViewController.swift
//  BDTSExamples
//
//  Created by Bart van Kuik on 03/04/2019.
//  Copyright © 2019 DutchVirtual. All rights reserved.
//

import UIKit
import BetterDynamicTypeSupport

class StepperViewController: UIViewController {
    private let bdtsStepper = BDTSStepper()
    private let resultTextField = UITextField()
    
    @objc func bdtsStepperValueChanged(_ sender: BDTSStepper) {
        self.resultTextField.text = "\(sender.value)"
    }
    
    @objc func configure() {
        let vc = ConfigureStepperViewController(self.bdtsStepper) {
            self.resultTextField.text = String(describing: self.bdtsStepper.value)
        }
        let nc = UINavigationController(rootViewController: vc)
        self.present(nc, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Views"
        
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 20
        self.view.addSubview(stackView)
        
        self.bdtsStepper.translatesAutoresizingMaskIntoConstraints = false
        self.bdtsStepper.addTarget(self, action: #selector(bdtsStepperValueChanged(_:)), for: .valueChanged)
        self.bdtsStepper.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        stackView.addArrangedSubview(self.bdtsStepper)
        
        let resultStackView = UIStackView()
        resultStackView.spacing = 20
        stackView.addArrangedSubview(resultStackView)
        
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .body)
        label.adjustsFontForContentSizeCategory = true
        label.text = "Result:"
        resultStackView.addArrangedSubview(label)
        
        self.resultTextField.font = .preferredFont(forTextStyle: .body)
        self.resultTextField.adjustsFontForContentSizeCategory = true
        self.resultTextField.placeholder = "No result yet"
        self.resultTextField.text = String(describing: self.bdtsStepper.value)
        self.resultTextField.isEnabled = false
        self.resultTextField.accessibilityLabel = "Result of stepper"
        resultStackView.addArrangedSubview(self.resultTextField)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose,
                                                                 target: self, action: #selector(configure))
        
        let guide =  self.view.safeAreaLayoutGuide
        let constraints = [
            stackView.topAnchor.constraint(equalToSystemSpacingBelow: guide.topAnchor, multiplier: 1),
            stackView.leadingAnchor.constraint(equalToSystemSpacingAfter: guide.leadingAnchor, multiplier: 1),
            guide.trailingAnchor.constraint(equalToSystemSpacingAfter: stackView.trailingAnchor, multiplier: 1)
        ]
        self.view.addConstraints(constraints)
    }
}

