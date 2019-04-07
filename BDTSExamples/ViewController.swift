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
    private let stepperLabel = UILabel()
    private let bdtsStepperLabel = UILabel()

    
    @objc func stepperValueChanged(_ sender: UIStepper) {
        self.stepperLabel.text = "\(sender.value)"
    }
    
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
        
        let searchBar = UISearchBar()
        searchBar.text = "UISearchBar"
        stackView.addArrangedSubview(searchBar)
        
        let bdtsSearchBar = BDTSSearchBar()
        bdtsSearchBar.text = "BDTSSearchBar"
        stackView.addArrangedSubview(bdtsSearchBar)
        
        let stepper = UIStepper()
        stepper.translatesAutoresizingMaskIntoConstraints = false
        stepper.addTarget(self, action: #selector(stepperValueChanged(_:)), for: .valueChanged)
        self.view.addSubview(stepper)
        
        let bdtsStepper = BDTSStepper()
        bdtsStepper.translatesAutoresizingMaskIntoConstraints = false
        bdtsStepper.addTarget(self, action: #selector(bdtsStepperValueChanged(_:)), for: .valueChanged)
        self.view.addSubview(bdtsStepper)
        
        stepperLabel.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(stepperLabel)
        
        bdtsStepperLabel.translatesAutoresizingMaskIntoConstraints = false
        bdtsStepperLabel.adjustsFontForContentSizeCategory = true
        bdtsStepperLabel.font = .preferredFont(forTextStyle: .body)
        self.view.addSubview(bdtsStepperLabel)
        
        let guide =  self.view.safeAreaLayoutGuide
        let constraints = [
            stackView.topAnchor.constraint(equalTo: guide.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: guide.trailingAnchor),
            stepper.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 20),
            stepper.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            stepperLabel.centerYAnchor.constraint(equalTo: stepper.centerYAnchor),
            stepperLabel.leftAnchor.constraint(equalToSystemSpacingAfter: stepper.rightAnchor, multiplier: 1),
            bdtsStepper.topAnchor.constraint(equalTo: stepper.bottomAnchor, constant: 20),
            bdtsStepper.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            bdtsStepperLabel.centerYAnchor.constraint(equalTo: bdtsStepper.centerYAnchor),
            bdtsStepperLabel.leftAnchor.constraint(equalToSystemSpacingAfter: bdtsStepper.rightAnchor, multiplier: 1),
        ]
        self.view.addConstraints(constraints)
    }
}

