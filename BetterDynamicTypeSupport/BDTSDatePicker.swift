//
//  BDTSDatePicker.swift
//  BetterDynamicTypeSupport
//
//  Originally by Christopher Jones on 3/30/15.
//  Adapted by Bart van Kuik on 10/04/2019.
//  Copyright © 2019 DutchVirtual. All rights reserved.
//

import UIKit

public class BDTSDatePicker: UIControl {
    public enum Mode {
        case date
        case dateAndTime
    }
    
    public var mode: Mode = .date {
        didSet {
            self.resetMode()
        }
    }
    
    private let dateDataSource = DateDataSource()
    private let dateAndTimeDataSource = DateAndTimeDataSource()
    private let datePickerViewDelegate = DatePickerViewDelegate()
    private let dateAndTimePickerViewDelegate = DateAndTimePickerViewDelegate()
    
    public var minimumDate: Date {
        get { return self.datePickerViewDelegate.minimumDate }
        set { self.datePickerViewDelegate.minimumDate = newValue }
    }
    public var maximumDate: Date {
        get { return self.datePickerViewDelegate.maximumDate }
        set { self.datePickerViewDelegate.maximumDate = newValue }
    }
    
    internal static let maximumNumberOfRows = Int(Int16.max)
    internal static let textStyle: UIFont.TextStyle = .body
    internal static let textColor = UIColor.black
    internal static var disabledTextColor : UIColor {
        get {
            var r : CGFloat = 0
            var g : CGFloat = 0
            var b : CGFloat = 0
            
            BDTSDatePicker.textColor.getRed(&r, green: &g, blue: &b, alpha: nil)
            
            return UIColor(red: r, green: g, blue: b, alpha: 0.35)
        }
    }
    
    /// The current date value of the date picker.
    public private(set) var date: Date {
        get {
            switch self.mode {
            case .date:
                return self.datePickerViewDelegate.date
            case .dateAndTime:
                return self.dateAndTimePickerViewDelegate.date
            }
        }
        set {
            self.datePickerViewDelegate.date = newValue
            self.dateAndTimePickerViewDelegate.date = newValue
        }
    }
    
    /// The internal picker view used for laying out the date components.
    private let pickerView = UIPickerView()
    private let dateAndTimeModeCounter = 0
    
    // MARK: - LifeCycle
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    func commonInit() {
        self.addSubview(self.pickerView)
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        let topConstraint = NSLayoutConstraint(item: self.pickerView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0)
        let bottomConstraint = NSLayoutConstraint(item: self.pickerView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0)
        let leftConstraint = NSLayoutConstraint(item: self.pickerView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0)
        let rightConstraint = NSLayoutConstraint(item: self.pickerView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0)
        
        self.addConstraints([topConstraint, bottomConstraint, leftConstraint, rightConstraint])
    }
    
    // MARK: - Static func
    
    // MARK: - Override
    
    public override var intrinsicContentSize : CGSize {
        return self.pickerView.intrinsicContentSize
    }
    
    public override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        self.resetMode()
        self.reloadAllComponents()
    }
    
    // MARK: - Public
    
    public func reloadAllComponents() {
        self.datePickerViewDelegate.refreshComponentOrdering()
        self.pickerView.reloadAllComponents()
    }
    
    public func setDate(_ date : Date, animated : Bool) {
        self.date = date
        self.updatePickerViewComponentValuesAnimated(animated)
    }
    
    // MARK: - Private
    
    private func resetMode() {
        switch self.mode {
        case .date:
            self.pickerView.dataSource = self.dateDataSource
            self.pickerView.delegate = self.datePickerViewDelegate
            self.datePickerViewDelegate.onChange = { [weak self] in
                if let date = self?.datePickerViewDelegate.date {
                    self?.date = date
                }
                self?.sendActions(for: .valueChanged)
            }
        case .dateAndTime:
            self.pickerView.dataSource = self.dateAndTimeDataSource
            self.pickerView.delegate = self.dateAndTimePickerViewDelegate
            self.dateAndTimePickerViewDelegate.onChange = { [weak self] in
                if let date = self?.dateAndTimePickerViewDelegate.date {
                    self?.date = date
                }
                self?.sendActions(for: .valueChanged)
            }
        }
        self.setDate(self.date)
    }
    
    private func setDate(_ date : Date) {
        self.setDate(date, animated: false)
    }
    

    private func updatePickerViewComponentValuesAnimated(_ animated : Bool) {
        switch self.mode {
        case .date:
            self.datePickerViewDelegate.updatePickerViewComponentValues(self.pickerView, animated)
        case .dateAndTime:
            self.dateAndTimePickerViewDelegate.updatePickerViewComponentValues(self.pickerView, animated)
        }
    }
    
}

