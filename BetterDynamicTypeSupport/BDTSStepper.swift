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
    private var nSteps: Int = 0
    private var originalValue: Double = 0.0

    public var value: Double {
        get {
            return self.originalValue + (Double(self.nSteps) * self.stepValue)
        }
        set {
            self.originalValue = newValue
            self.nSteps = 0
            self.sendActions(for: .valueChanged)
        }
    }
    public var stepValue: Double = 1.0 {
        didSet {
            if self.stepValue <= 0 {
                NSException(name: .invalidArgumentException, reason: "stepValue <= 0", userInfo: nil).raise()
            }
        }
    }
    public var minimumValue: Double = 0.0 {
        didSet {
            if self.minimumValue >= self.maximumValue {
                NSException(name: .invalidArgumentException, reason: "minimumValue >= maximumValue", userInfo: nil).raise()
            }
            if self.minimumValue >= value {
                self.value = self.minimumValue
            }
        }
    }
    public var maximumValue: Double = 100.0 {
        didSet {
            if self.maximumValue <= self.minimumValue {
                NSException(name: .invalidArgumentException, reason: "maximumValue <= minimumValue", userInfo: nil).raise()
            }
            if self.value >= self.maximumValue {
                self.value = self.maximumValue
            }
        }
    }
    public var autorepeat: Bool {
        get {
            return self.minus.autorepeat && self.plus.autorepeat
        }
        set {
            self.minus.autorepeat = newValue
            self.plus.autorepeat = newValue
        }
    }
    
    private func nextValueForNSteps(_ nSteps: Int, direction: Int) -> Double {
        let nextValue: Double
        if direction > 0 {
            nextValue = self.originalValue + (Double(self.nSteps + 1) * self.stepValue)
        } else if direction < 0 {
            nextValue = self.originalValue + (Double(self.nSteps - 1) * self.stepValue)
        } else {
            fatalError("Programmer error")
        }
        
        return nextValue
    }
    
    private func decrement() {
        let nextValue = self.nextValueForNSteps(self.nSteps - 1, direction: -1)
        
        if nextValue < self.minimumValue {
            self.refreshView()
        } else {
            self.nSteps -= 1
            self.sendActions(for: .valueChanged)
            self.refreshView()
        }
    }

    private func increment() {
        let nextValue = self.nextValueForNSteps(self.nSteps + 1, direction: 1)
        
        if nextValue > self.maximumValue {
            self.refreshView()
        } else {
            self.nSteps += 1
            self.sendActions(for: .valueChanged)
            self.refreshView()
        }
    }
    
    private func refreshView() {
        self.minus.isEnabled = (self.value > self.minimumValue)
        self.plus.isEnabled = (self.value < self.maximumValue)
        
        self.minus.alpha = self.minus.isEnabled ? 1.0 : 0.598
        self.plus.alpha = self.plus.isEnabled ? 1.0 : 0.598
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
        
        self.minus.translatesAutoresizingMaskIntoConstraints = true
        self.minus.action = { [weak self] in
            self?.decrement()
        }
        
        self.plus.translatesAutoresizingMaskIntoConstraints = true
        self.plus.action = { [weak self] in
            self?.increment()
        }

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
        self.refreshView()
    }
}
