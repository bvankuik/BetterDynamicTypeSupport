//
//  BDTSStepper.swift
//  BetterDynamicTypeSupport
//
//  Created by Bart van Kuik on 06/04/2019.
//  Copyright © 2019 DutchVirtual. All rights reserved.
//

import UIKit

open class BDTSStepper: UIControl {
    private static let defaultTint = UIColor(red: 0.192, green: 0.478, blue: 0.965, alpha: 1)
    private let foregroundColor = BDTSStepper.defaultTint
    private let disabledColor = UIColor(red: 0.545, green: 0.733, blue: 0.976, alpha: 1)
    private var constraintsInstalled = false
    private let buttonPressedColor = UIColor(red: 0.863, green: 0.922, blue: 0.922, alpha: 1)
    private let minus = PlusMinusControl(foregroundColor: BDTSStepper.defaultTint, direction: -1)
    private let plus = PlusMinusControl(foregroundColor: BDTSStepper.defaultTint, direction: 1)

    public var value: Double = 0.0 {
        didSet {
            self.sendActions(for: .valueChanged)
        }
    }
    var stepValue: Double = 1.0
    
    @objc func decrement() {
        self.value -= stepValue
    }

    @objc func increment() {
        self.value += stepValue
    }
    
    private func refreshHandlers() {
        minus.addTarget(self, action: #selector(decrement), for: .touchUpInside)
        plus.addTarget(self, action: #selector(increment), for: .touchUpInside)
    }
    
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
        
        
        minus.translatesAutoresizingMaskIntoConstraints = true
        
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
        
        self.refreshHandlers()
    }
}
