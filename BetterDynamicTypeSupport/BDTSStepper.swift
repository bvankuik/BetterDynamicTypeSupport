//
//  BDTSStepper.swift
//  BetterDynamicTypeSupport
//
//  Created by Bart van Kuik on 06/04/2019.
//  Copyright © 2019 DutchVirtual. All rights reserved.
//

import UIKit

open class BDTSStepper: UIView {
    private let foregroundColor: UIColor = .blue
    private var constraintsInstalled = false

    public init() {
        super.init(frame: .zero)
        self.commonInit()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    private func commonInit() {
        self.layer.borderWidth = 1
        self.layer.borderColor = self.foregroundColor.cgColor
        self.layer.cornerRadius = 3
        
        let divider = UIView()
        divider.translatesAutoresizingMaskIntoConstraints = false
        divider.backgroundColor = self.foregroundColor
        self.addSubview(divider)
        
        let minus = PlusMinusControl(foregroundColor: self.foregroundColor, step: -1)
        minus.translatesAutoresizingMaskIntoConstraints = true
        
        let plus = PlusMinusControl(foregroundColor: self.foregroundColor, step: 1)
        plus.translatesAutoresizingMaskIntoConstraints = true

        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(stackView)
        
        
        stackView.addArrangedSubview(minus)
        stackView.addArrangedSubview(divider)
        stackView.addArrangedSubview(plus)
        
        let constraints = [
            stackView.topAnchor.constraint(equalTo: self.topAnchor),
            stackView.leftAnchor.constraint(equalTo: self.leftAnchor),
            stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            stackView.rightAnchor.constraint(equalTo: self.rightAnchor),

            divider.widthAnchor.constraint(equalToConstant: 1)
        ]
        self.addConstraints(constraints)
    }
}
