//
//  PlusMinusControl.swift
//  BetterDynamicTypeSupport
//
//  Created by Bart van Kuik on 07/04/2019.
//  Copyright © 2019 DutchVirtual. All rights reserved.
//

import UIKit

class PlusMinusControl: UIControl {
    let foregroundColor: UIColor
    private var constraintsInstalled = false
    private let step: Int
    private let horizontalStripe = UIView()
    private let verticalStripe = UIView()
    private let plus = UIView()
    private let label = UILabel()
    
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
            self.horizontalStripe.widthAnchor.constraint(equalTo: self.label.widthAnchor, multiplier: 0.48)
        ]
        self.addConstraints(constraints)
        
        if self.step > 0 {
            let additionalConstraints = [
                self.verticalStripe.centerXAnchor.constraint(equalTo: self.horizontalStripe.centerXAnchor),
                self.verticalStripe.centerYAnchor.constraint(equalTo: self.horizontalStripe.centerYAnchor),
                self.verticalStripe.widthAnchor.constraint(equalTo: self.horizontalStripe.heightAnchor),
                self.verticalStripe.heightAnchor.constraint(equalTo: self.horizontalStripe.widthAnchor)
            ]
            self.addConstraints(additionalConstraints)
        }
    }
    
    init(foregroundColor: UIColor, step: Int){
        self.foregroundColor = foregroundColor
        self.step = step
        super.init(frame: .zero)
        
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
        
        if self.step > 0 {
            self.addSubview(self.verticalStripe)
        }
    }
    
    private override init(frame: CGRect) {
        self.foregroundColor = .red
        self.step = 0
        super.init(frame: frame)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}
