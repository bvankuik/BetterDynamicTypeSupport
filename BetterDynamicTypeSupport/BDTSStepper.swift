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
    private let divider = UIView()
    
    open override func tintColorDidChange() {
        if self.tintAdjustmentMode == .dimmed {
            self.layer.borderColor = UIColor.lightGray.cgColor
            self.divider.backgroundColor = .lightGray
        } else {
            self.layer.borderColor = self.foregroundColor.cgColor
            self.divider.backgroundColor = self.foregroundColor
        }
    }

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
        self.accessibilityLabel = "Stepper"
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 4
        
        self.divider.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.divider)
        
        self.minus.translatesAutoresizingMaskIntoConstraints = false
        self.minus.accessibilityLabel = "Stepper decrement"
        self.minus.action = { [weak self] in
            self?.decrement()
        }
        self.addSubview(self.minus)
        
        self.plus.translatesAutoresizingMaskIntoConstraints = false
        self.plus.accessibilityLabel = "Stepper increment"
        self.plus.action = { [weak self] in
            self?.increment()
        }
        self.addSubview(self.plus)

        let constraints = [
            self.minus.topAnchor.constraint(equalTo: self.topAnchor),
            self.minus.leftAnchor.constraint(equalTo: self.leftAnchor),
            self.minus.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            
            self.plus.topAnchor.constraint(equalTo: self.topAnchor),
            self.plus.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            self.plus.rightAnchor.constraint(equalTo: self.rightAnchor),

            self.divider.topAnchor.constraint(equalTo: self.topAnchor),
            self.divider.leftAnchor.constraint(equalTo: self.minus.rightAnchor),
            self.divider.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            self.divider.rightAnchor.constraint(equalTo: self.plus.leftAnchor),
            self.divider.widthAnchor.constraint(equalToConstant: 1),
            
            self.plus.widthAnchor.constraint(equalTo: self.minus.widthAnchor)
        ]
        self.addConstraints(constraints)
        self.refreshView()
        self.tintColorDidChange()
    }
}
