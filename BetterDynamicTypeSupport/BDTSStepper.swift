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
    private var constraintsInstalled = false
    private let minus = PlusMinusControl(foregroundColor: BDTSStepper.defaultTint, direction: -1)
    private let plus = PlusMinusControl(foregroundColor: BDTSStepper.defaultTint, direction: 1)

    public var value: Double = 0.0 {
        didSet {
            self.sendActions(for: .valueChanged)
        }
    }
    var stepValue: Double = 1.0
    var minimumValue: Double = 0.0
    var maximumValue: Double = 100.0
    
    @objc func decrement() {
        if self.value > self.minimumValue {
            self.value -= self.stepValue
        }

        self.refreshView()
    }

    @objc func increment() {
        if self.value < self.maximumValue {
            self.value += self.stepValue
        }
        
        self.refreshView()
    }
    
    private func refreshView() {
        self.minus.isEnabled = (self.value > self.minimumValue)
        self.plus.isEnabled = (self.value < self.maximumValue)
        
        self.minus.alpha = self.minus.isEnabled ? 1.0 : 0.598
        self.plus.alpha = self.plus.isEnabled ? 1.0 : 0.598
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
        self.layer.cornerRadius = 4
        
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
        self.refreshView()
    }
}
