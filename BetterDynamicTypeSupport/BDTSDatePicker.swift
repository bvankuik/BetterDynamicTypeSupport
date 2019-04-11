//
//  BDTSDatePicker.swift
//  BetterDynamicTypeSupport
//
//  Created by Christopher Jones on 3/30/15.
//  Adapted by Bart van Kuik on 10/04/2019.
//  Copyright © 2019 DutchVirtual. All rights reserved.
//

public protocol BDTSDatePickerDelegate {
    func pickerView(_ pickerView: BDTSDatePicker, didSelectRow row: Int, inComponent component: Int)
}

public class BDTSDatePicker: UIControl, UIPickerViewDataSource, UIPickerViewDelegate {
    enum Components : Character  {
        case invalid = "!",
        year = "y",
        month = "M",
        day = "d"
    }
    public enum Mode {
        case date
        case dateAndTime
    }
    public var mode: Mode = .date {
        didSet {
            self.setDate(self.date)
        }
    }

    // MARK: -
    // MARK: Public Properties
    public var delegate: BDTSDatePickerDelegate?
    
    private let textStyle: UIFont.TextStyle = .body
    private var textColor = UIColor.black
    /// The minimum date to show for the date picker. Set to NSDate.distantPast() by default
    public var minimumDate = Date.distantPast {
        didSet {
            self.validateMinimumAndMaximumDate()
        }
    }
    
    /// The maximum date to show for the date picker. Set to NSDate.distantFuture() by default
    public var maximumDate = Date.distantFuture {
        didSet {
            self.validateMinimumAndMaximumDate()
        }
    }
    
    /// The current locale to use for formatting the date picker. By default, set to the device's current locale
    public var locale : Locale = Locale.current {
        didSet {
            self.calendar.locale = self.locale
        }
    }
    private lazy var sizeForDigit: CGSize = {
        let size = self.sizeForDynamicTypeLabelWithText("9")
        return size
    }()
    
    /// The current date value of the date picker.
    
    public private(set) var date = Date()
    // MARK: -
    // MARK: Private Variables
    
    private let maximumNumberOfRows = Int(Int16.max)
    
    /// The internal picker view used for laying out the date components.
    private let pickerView = UIPickerView()
    private let labelForSizeMeasurement = UILabel()
    private let dateAndTimeModeCounter = 0
    
    /// The calendar used for formatting dates.
    
    /// Calculates the current calendar components for the current date.
    private var calendar = Calendar(identifier: Calendar.Identifier.gregorian)
    private var currentCalendarComponents : DateComponents {
        get {
            return (self.calendar as NSCalendar).components([.year, .month, .day], from: self.date)
        }
    }
    
    /// Gets the text color to be used for the label in a disabled state
    private var disabledTextColor : UIColor {
        get {
            var r : CGFloat = 0
            var g : CGFloat = 0
            var b : CGFloat = 0
            
            self.textColor.getRed(&r, green: &g, blue: &b, alpha: nil)
            
            return UIColor(red: r, green: g, blue: b, alpha: 0.35)
        }
    }
    
    private lazy var dateFormatterForDateMode: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = self.calendar
        dateFormatter.locale = self.locale
        
        return dateFormatter
    }()

    private lazy var dateFormatterForDateAndTimeMode: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = self.calendar
        dateFormatter.locale = self.locale
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        return dateFormatter
    }()

    /// The order in which each component should be ordered in.
    private var datePickerComponentOrdering = [Components]()
    
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
        self.pickerView.dataSource = self
        self.pickerView.delegate = self
        
        self.addSubview(self.pickerView)
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        let topConstraint = NSLayoutConstraint(item: self.pickerView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0)
        let bottomConstraint = NSLayoutConstraint(item: self.pickerView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0)
        let leftConstraint = NSLayoutConstraint(item: self.pickerView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0)
        let rightConstraint = NSLayoutConstraint(item: self.pickerView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0)
        
        self.addConstraints([topConstraint, bottomConstraint, leftConstraint, rightConstraint])
    }
    
    // MARK: - Override
    public override var intrinsicContentSize : CGSize {
        return self.pickerView.intrinsicContentSize
    }
    
    public override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        self.reloadAllComponents()
    }
    
    // MARK: - Public
    
    public func reloadAllComponents() {
        self.refreshComponentOrdering()
        self.pickerView.reloadAllComponents()
    }
    
    public func setDate(_ date : Date, animated : Bool) {
        self.date = date
        self.updatePickerViewComponentValuesAnimated(animated)
    }
    
    // MARK: -
    // MARK: Private
    
    private func sizeForNumericLabel(nDigits: Int) -> CGSize {
        let size = self.sizeForDigit
        return CGSize(width: size.width * CGFloat(nDigits), height: size.height * CGFloat(nDigits))
    }
    
    private func sizeForDynamicTypeLabelWithText(_ text: String) -> CGSize {
        self.labelForSizeMeasurement.text = text
        self.labelForSizeMeasurement.font = .preferredFont(forTextStyle: self.textStyle)
        self.labelForSizeMeasurement.adjustsFontForContentSizeCategory = true
        
        let size = self.labelForSizeMeasurement.systemLayoutSizeFitting(.zero)
        return size
    }
    
    /**
     Sets the current date with no animation.
     
     :param: date The date to be set.
     */
    private func setDate(_ date : Date) {
        self.setDate(date, animated: false)
    }
    
    private func refreshComponentOrdering() {
        guard var componentOrdering = DateFormatter.dateFormat(fromTemplate: "yMMMMd", options: 0, locale: self.locale) else {
            return
        }
        
        let firstComponentOrderingString = componentOrdering[componentOrdering.index(componentOrdering.startIndex, offsetBy: 0)]
        let lastComponentOrderingString = componentOrdering[componentOrdering.index(componentOrdering.startIndex, offsetBy: componentOrdering.count - 1)]
        
        var characterSet = CharacterSet(charactersIn: String(firstComponentOrderingString) + String(lastComponentOrderingString))
        characterSet = characterSet.union(CharacterSet.whitespacesAndNewlines).union(CharacterSet.punctuationCharacters)
        
        componentOrdering = componentOrdering.trimmingCharacters(in: characterSet)
        let remainingValue = componentOrdering[componentOrdering.index(componentOrdering.startIndex, offsetBy: 0)]
        
        guard
            let firstComponent = Components(rawValue: firstComponentOrderingString),
            let secondComponent = Components(rawValue: remainingValue),
            let lastComponent = Components(rawValue: lastComponentOrderingString) else {
                return
        }
        
        self.datePickerComponentOrdering = [firstComponent, secondComponent, lastComponent]
    }
    
    /**
     Validates that the set minimum and maximum dates are valid.
     */
    private func validateMinimumAndMaximumDate() {
        let ordering = self.minimumDate.compare(self.maximumDate)
        if (ordering != .orderedAscending ){
            fatalError("Cannot set a maximum date that is equal or less than the minimum date.")
        }
    }
    
    /**
     Gets the value of the current component at the specified row.
     
     :param: row            The row index whose value is required
     :param: componentIndex The component index for the row.
     
     :returns: A string containing the value of the current row at the component index.
     */
    private func titleForRow(_ row : Int, inComponentIndex componentIndex: Int) -> String {
        switch self.mode {
        case .date:
            let dateComponent = self.componentAtIndex(componentIndex)
            
            let value = self.rawValueForRow(row, inComponent: dateComponent)
            
            if dateComponent == Components.month {
                let dateFormatter = self.dateFormatterForDateMode
                return dateFormatter.monthSymbols[value - 1]
            } else {
                return String(value)
            }
        case .dateAndTime:
            if componentIndex == 0 {
                let normalizedRow = row - (self.maximumNumberOfRows / 2)
                if normalizedRow == 0 {
                    return "Today"
                } else {
                    var components = DateComponents()
                    components.day = normalizedRow
                    let dateToDisplay = Calendar.current.date(byAdding: components, to: Date()) ?? Date()
                    let string = self.dateFormatterForDateAndTimeMode.string(from: dateToDisplay)
                    return string
                }
            } else if componentIndex == 1 {
                return "12"
            } else {
                return "00"
            }
        }
    }
    
    private func valueForDateComponent(_ component : Components) -> Int{
        if component == .year {
            return self.currentCalendarComponents.year!
        } else if component == .day {
            return self.currentCalendarComponents.day!
        } else {
            return self.currentCalendarComponents.month!
        }
    }
    
    private func maximumRangeForComponent(_ component : Components) -> NSRange {
        var calendarUnit : NSCalendar.Unit
        if component == .year {
            calendarUnit = .year
        } else if component == .day {
            calendarUnit = .day
        } else {
            calendarUnit = .month
        }
        
        return (self.calendar as NSCalendar).maximumRange(of: calendarUnit)
    }
    
    private func rawValueForRow(_ row : Int, inComponent component : Components) -> Int {
        let calendarUnitRange = self.maximumRangeForComponent(component)
        return calendarUnitRange.location + (row % calendarUnitRange.length)
    }
    
    private func isRowEnabled(_ row: Int, forComponent component : Components) -> Bool {
        
        let rawValue = self.rawValueForRow(row, inComponent: component)
        
        var components = DateComponents()
        components.year = self.currentCalendarComponents.year
        components.month = self.currentCalendarComponents.month
        components.day = self.currentCalendarComponents.day
        
        if component == .year {
            components.year = rawValue
        } else if component == .day {
            components.day = rawValue
        } else if component == .month {
            components.month = rawValue
        }
        
        let dateForRow = self.calendar.date(from: components)!
        
        return self.dateIsInRange(dateForRow)
    }
    
    private func dateIsInRange(_ date : Date) -> Bool {
        return self.minimumDate.compare(date) != ComparisonResult.orderedDescending &&
            self.maximumDate.compare(date) != ComparisonResult.orderedAscending
    }
    
    private func updatePickerViewComponentValuesAnimated(_ animated : Bool) {
        switch self.mode {
        case .date:
            for (_, dateComponent) in self.datePickerComponentOrdering.enumerated() {
                self.setIndexOfComponent(dateComponent, animated: animated)
            }
        case .dateAndTime:
            self.pickerView.selectRow((self.maximumNumberOfRows / 2), inComponent: 0, animated: animated)
            self.pickerView.selectRow(0, inComponent: 1, animated: animated)
            self.pickerView.selectRow(0, inComponent: 2, animated: animated)
        }
    }
    
    private func setIndexOfComponent(_ component : Components, animated: Bool) {
        self.setIndexOfComponent(component, toValue: self.valueForDateComponent(component), animated: animated)
    }
    
    private func setIndexOfComponent(_ component : Components, toValue value : Int, animated: Bool) {
        let componentRange = self.maximumRangeForComponent(component)
        
        let idx = (value - componentRange.location)
        let middleIndex = (self.maximumNumberOfRows / 2) - (maximumNumberOfRows / 2) % componentRange.length + idx
        
        var componentIndex = 0
        
        for (index, dateComponent) in self.datePickerComponentOrdering.enumerated() {
            if (dateComponent == component) {
                componentIndex = index
            }
        }
        
        self.pickerView.selectRow(middleIndex, inComponent: componentIndex, animated: animated)
    }
    
    private func componentAtIndex(_ index: Int) -> Components {
        return self.datePickerComponentOrdering[index]
    }
    
    private func numberOfDaysForMonth(_ month : Int, inYear year : Int) -> Int {
        var components = DateComponents()
        components.month = month
        components.day = 1
        components.year = year
        
        let calendarRange = (self.calendar as NSCalendar).range(of: .day, in: .month, for: self.calendar.date(from: components)!)
        let numberOfDaysInMonth = calendarRange.length
        
        return numberOfDaysInMonth
    }
    
    // Determines if updating the specified component to the input value would evaluate to a valid date using the
    // current date values.
    private func isValidValue(_ value : Int, forComponent component: Components) -> Bool {
        if (component == .year) {
            let numberOfDaysInMonth = self.numberOfDaysForMonth(self.currentCalendarComponents.month!, inYear: value)
            return self.currentCalendarComponents.day! <= numberOfDaysInMonth
        } else if (component == .day) {
            let numberOfDaysInMonth = self.numberOfDaysForMonth(self.currentCalendarComponents.month!, inYear: self.currentCalendarComponents.year!)
            return value <= numberOfDaysInMonth
        } else if (component == .month) {
            let numberOfDaysInMonth = self.numberOfDaysForMonth(value, inYear: self.currentCalendarComponents.year!)
            return self.currentCalendarComponents.day! <= numberOfDaysInMonth
        }
        
        return true
    }
    
    // Creates date components by updating the specified component to the input value. Does not do any date validation.
    private func currentCalendarComponentsByUpdatingComponent(_ component : Components, toValue value : Int) -> DateComponents {
        var components = self.currentCalendarComponents
        
        if (component == .month) {
            components.month = value
        } else if (component == .day) {
            components.day = value
        } else {
            components.year = value
        }
        
        return components
    }
    
    // Creates date components by updating the specified component to the input value. If the resulting value is not
    // a valid date object, the components will be updated to the closest best value.
    private func validDateValueByUpdatingComponent(_ component : Components, toValue value : Int) -> DateComponents {
        var components = self.currentCalendarComponentsByUpdatingComponent(component, toValue: value)
        if (!self.isValidValue(value, forComponent: component)) {
            if (component == .month) {
                components.day = self.numberOfDaysForMonth(value, inYear: components.year!)
            } else if (component == .day) {
                components.day = self.numberOfDaysForMonth(components.month!, inYear:components.year!)
            } else {
                components.day = self.numberOfDaysForMonth(components.month!, inYear: value)
            }
        }
        
        return components
    }
    
    // MARK: - UIPickerViewDelegate
    
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let datePickerComponent = self.componentAtIndex(component)
        let value = self.rawValueForRow(row, inComponent: datePickerComponent)
        
        // Create the newest valid date components.
        let components = self.validDateValueByUpdatingComponent(datePickerComponent, toValue: value)
        
        // If the resulting components are not in the date range ...
        if (!self.dateIsInRange(self.calendar.date(from: components)!)) {
            // ... go back to original date
            self.setDate(self.date, animated: true)
        } else {
            // Get the components that would result by just force-updating the current components.
            let rawComponents = self.currentCalendarComponentsByUpdatingComponent(datePickerComponent, toValue: value)
            
            let day = components.day!
            
            if (rawComponents.day != components.day) {
                // Only animate the change if the day value is not a valid date.
                self.setIndexOfComponent(.day, toValue: day, animated: self.isValidValue(day, forComponent: .day))
            }
            
            if (rawComponents.month != components.month) {
                self.setIndexOfComponent(.month, toValue: day, animated: datePickerComponent != .month)
            }
            
            if (rawComponents.year != components.year) {
                self.setIndexOfComponent(.year, toValue: day, animated: datePickerComponent != .year)
            }
            
            self.date = self.calendar.date(from: components)!
            self.sendActions(for: .valueChanged)
        }
        
        self.delegate?.pickerView(self, didSelectRow: row, inComponent: component)
    }
    
    public func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = view as? UILabel == nil ? UILabel() : view as! UILabel
        
        label.font = .preferredFont(forTextStyle: self.textStyle)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = self.textColor
        label.text = self.titleForRow(row, inComponentIndex: component)
        label.textAlignment = self.componentAtIndex(component) == .month ? NSTextAlignment.left : NSTextAlignment.right
        label.textColor = self.isRowEnabled(row, forComponent: self.componentAtIndex(component)) ? self.textColor : self.disabledTextColor
        
        return label
    }
    
    public func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        switch self.mode {
        case .date:
            let widthBuffer: CGFloat = 25.0
            
            let calendarComponent = self.componentAtIndex(component)
            var size: CGFloat = 0.01
            
            if calendarComponent == .month {
                
                // Get the length of the longest month string and set the size to it.
                for symbol in self.dateFormatterForDateMode.monthSymbols as [String] {
                    let monthSize = self.sizeForDynamicTypeLabelWithText(symbol)
                    size = max(size, monthSize.width)
                }
            } else if calendarComponent == .day {
                size = self.sizeForNumericLabel(nDigits: 2).width
            } else if calendarComponent == .year {
                size = self.sizeForNumericLabel(nDigits: 4).width
            }
            
            // Add the width buffer in order to allow the picker components not to run up against the edges
            return size + widthBuffer
        case .dateAndTime:
            if component == 0 {
                return self.sizeForDynamicTypeLabelWithText("WWW 99 WWW").width
            } else {
                return self.sizeForNumericLabel(nDigits: 2).width
            }
        }
    }
    
    public func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        let size = self.sizeForDynamicTypeLabelWithText("99")
        return size.height
    }
    
    // MARK: - UIPickerViewDataSource
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.maximumNumberOfRows
    }
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
}
