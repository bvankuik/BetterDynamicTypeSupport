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
        self.view.addSubview(stepper)
        
        let bdtsStepper = BDTSStepper()
        bdtsStepper.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(bdtsStepper)
        
        let guide =  self.view.safeAreaLayoutGuide
        let constraints = [
            stackView.topAnchor.constraint(equalTo: guide.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: guide.trailingAnchor),
            stepper.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 20),
            stepper.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            bdtsStepper.topAnchor.constraint(equalTo: stepper.bottomAnchor, constant: 20),
            bdtsStepper.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
        ]
        self.view.addConstraints(constraints)
    }
}

