//
//  PlusMinusControl.swift
//  BetterDynamicTypeSupport
//
//  Created by Bart van Kuik on 07/04/2019.
//  Copyright © 2019 DutchVirtual. All rights reserved.
//

import UIKit

class PlusMinusControl: UIControl {
    private let foregroundColor: UIColor
    private let direction: Int
    private let horizontalStripe = UIView()
    private let verticalStripe = UIView()
    private let plus = UIView()
    private let label = UILabel()
    private var constraintsInstalled = false
    private var timerFireCounter = 0
    private var timer: Timer?
    var action: (() -> Void)?
    var autorepeat = true
    
    @objc func touchUp() {
        if self.timerFireCounter == 0 {
            self.action?()
        }
        self.timer?.invalidate()
        self.timerFireCounter = 0
    }
    
    @objc func touchDown() {
        guard self.autorepeat else {
            return
        }
        
        let timer = Timer(fire: Date().addingTimeInterval(0.5), interval: 0.5, repeats: true) { _ in
            self.timerFireCounter += 1
            self.action?()
            if self.timerFireCounter > 4 {
                self.timer?.invalidate()
                let fasterTimer = Timer(fire: Date().addingTimeInterval(0.1), interval: 0.1, repeats: true) { _ in
                    self.action?()
                }
                RunLoop.current.add(fasterTimer, forMode: .common)
                self.timer = fasterTimer
            }
        }
        RunLoop.current.add(timer, forMode: .common)
        self.timerFireCounter = 0
        self.timer = timer
    }
    
    override var isHighlighted: Bool {
        didSet {
            if self.isHighlighted {
                self.backgroundColor = UIColor(red: 0.863, green: 0.922, blue: 0.992, alpha: 1)
            } else {
                self.backgroundColor = .clear
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard !self.constraintsInstalled else {
            return
        }
        
        self.constraintsInstalled = true
        let constraints = [
            self.label.topAnchor.constraint(equalTo: self.topAnchor, constant: 4.5),
            self.label.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 7),
            self.label.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -4.5),
            self.label.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -7),
            
            self.horizontalStripe.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            self.horizontalStripe.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            self.horizontalStripe.heightAnchor.constraint(equalToConstant: 1.5),
            self.horizontalStripe.widthAnchor.constraint(equalTo: self.label.heightAnchor, multiplier: 0.73)
            // width should be 41
        ]
        self.addConstraints(constraints)
        
        if self.direction > 0 {
            let additionalConstraints = [
                self.verticalStripe.centerXAnchor.constraint(equalTo: self.horizontalStripe.centerXAnchor),
                self.verticalStripe.centerYAnchor.constraint(equalTo: self.horizontalStripe.centerYAnchor),
                self.verticalStripe.widthAnchor.constraint(equalTo: self.horizontalStripe.heightAnchor),
                self.verticalStripe.heightAnchor.constraint(equalTo: self.horizontalStripe.widthAnchor)
            ]
            self.addConstraints(additionalConstraints)
        }
    }
    
    init(foregroundColor: UIColor, direction: Int) {
        self.foregroundColor = foregroundColor
        self.direction = direction
        super.init(frame: .zero)
        
        // This label is hidden but makes the view expand/contract when the font size changes
        self.label.translatesAutoresizingMaskIntoConstraints = false
        self.label.text = "WW"
        self.label.font = .preferredFont(forTextStyle: .body)
        self.label.textColor = .blue
        self.label.adjustsFontForContentSizeCategory = true
        self.label.isHidden = true

        self.addSubview(self.label)
        
        self.horizontalStripe.translatesAutoresizingMaskIntoConstraints = false
        self.horizontalStripe.backgroundColor = self.foregroundColor
        self.addSubview(self.horizontalStripe)
        
        self.verticalStripe.translatesAutoresizingMaskIntoConstraints = false
        self.verticalStripe.backgroundColor = self.foregroundColor
        
        if self.direction > 0 {
            self.addSubview(self.verticalStripe)
        }
        
        self.addTarget(self, action: #selector(touchUp), for: .touchUpInside)
        self.addTarget(self, action: #selector(touchUp), for: .touchUpOutside)
        self.addTarget(self, action: #selector(touchDown), for: .touchDown)
    }
    
    private override init(frame: CGRect) {
        self.foregroundColor = .red
        self.direction = 0
        super.init(frame: frame)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}
