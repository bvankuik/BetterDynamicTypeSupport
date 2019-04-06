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
        
        let button = UIButton()
        button.setTitle("UIButton", for: .normal)
        button.backgroundColor = .blue
        button.setTitleColor(.white, for: .normal)
        stackView.addArrangedSubview(button)

        let bdtsButton = BDTSButton()
        bdtsButton.setTitle("BDTSButton", for: .normal)
        bdtsButton.backgroundColor = .blue
        bdtsButton.setTitleColor(.white, for: .normal)
        stackView.addArrangedSubview(bdtsButton)
        
        let textField = UITextField()
        textField.placeholder = "UITextField"
        stackView.addArrangedSubview(textField)
    
        let bdtsTextField = BDTSTextField()
        bdtsTextField.placeholder = "BDTSTextField"
        stackView.addArrangedSubview(bdtsTextField)
        
        let guide =  self.view.safeAreaLayoutGuide
        let constraints = [
            stackView.topAnchor.constraint(equalTo: guide.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: guide.trailingAnchor)
        ]
        self.view.addConstraints(constraints)
    }
}

