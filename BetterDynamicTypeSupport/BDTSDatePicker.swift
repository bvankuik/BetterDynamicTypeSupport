//
//  BDTSDatePicker.swift
//  BetterDynamicTypeSupport
//
//  Created by Christopher Jones on 3/30/15.
//  Adapted by Bart van Kuik on 10/04/2019.
//  Copyright © 2019 DutchVirtual. All rights reserved.
//


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
    
    fileprivate static var sizeForDigit: CGSize = {
        let size = BDTSDatePicker.sizeForDynamicTypeLabelWithText("9")
        return size
    }()

    private static let labelForSizeMeasurement = UILabel()
    fileprivate static let maximumNumberOfRows = Int(Int16.max)
    fileprivate static let textStyle: UIFont.TextStyle = .body
    fileprivate static let textColor = UIColor.black
    fileprivate static var disabledTextColor : UIColor {
        get {
            var r : CGFloat = 0
            var g : CGFloat = 0
            var b : CGFloat = 0
            
            BDTSDatePicker.textColor.getRed(&r, green: &g, blue: &b, alpha: nil)
            
            return UIColor(red: r, green: g, blue: b, alpha: 0.35)
        }
    }
    fileprivate static var hasAMPM: Bool {
        let formatString: String = DateFormatter.dateFormat(fromTemplate: "j", options: 0, locale: Locale.current)!
        return formatString.contains("a")
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
    
    fileprivate static func sizeForDynamicTypeLabelWithText(_ text: String) -> CGSize {
        BDTSDatePicker.labelForSizeMeasurement.text = text
        BDTSDatePicker.labelForSizeMeasurement.font = .preferredFont(forTextStyle: BDTSDatePicker.textStyle)
        BDTSDatePicker.labelForSizeMeasurement.adjustsFontForContentSizeCategory = true
        
        let size = BDTSDatePicker.labelForSizeMeasurement.systemLayoutSizeFitting(.zero)
        return size
    }
    
    fileprivate static func sizeForNumericLabel(nDigits: Int) -> CGSize {
        let size = BDTSDatePicker.sizeForDigit
        return CGSize(width: size.width * CGFloat(nDigits), height: size.height * CGFloat(nDigits))
    }
    
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

fileprivate class DateAndTimeDataSource: NSObject, UIPickerViewDataSource {
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 3 {
            return 2
        } else {
            return BDTSDatePicker.maximumNumberOfRows
        }
    }
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return (BDTSDatePicker.hasAMPM ? 4 : 3)
    }
}

fileprivate class DateDataSource: NSObject, UIPickerViewDataSource {
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return BDTSDatePicker.maximumNumberOfRows
    }
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
}

fileprivate class BasePickerViewDelegate: NSObject {
    internal let baseOffsetDate = Date()
    internal var date = Date()
    internal var onChange: (() -> Void)?
}

fileprivate class DateAndTimePickerViewDelegate: BasePickerViewDelegate, UIPickerViewDelegate {
    private lazy var formatterForDateAndTimeMode: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar.current
        dateFormatter.locale = Locale.current
        dateFormatter.dateFormat = "E MMM d"
        return dateFormatter
    }()
    
    internal func updatePickerViewComponentValues(_ pickerView: UIPickerView, _ animated: Bool) {
        let middleRow = (BDTSDatePicker.maximumNumberOfRows / 2)
        let (_, hourRemainder) = middleRow.quotientAndRemainder(dividingBy: 24)
        let hourStartRow = middleRow - hourRemainder
        
        pickerView.selectRow(middleRow, inComponent: 0, animated: animated)
        
        let components = Calendar.current.dateComponents([.hour, .minute], from: self.date)
        
        let hour = components.hour ?? 0
        if BDTSDatePicker.hasAMPM {
            if hour == 0 {
                pickerView.selectRow(hourStartRow + 11, inComponent: 1, animated: animated)
                pickerView.selectRow(0, inComponent: 3, animated: animated)
            } else if hour > 12 {
                pickerView.selectRow(hourStartRow + (hour - 13), inComponent: 1, animated: animated)
                pickerView.selectRow(1, inComponent: 3, animated: animated)
            } else {
                pickerView.selectRow(hourStartRow + hour, inComponent: 1, animated: animated)
                pickerView.selectRow(0, inComponent: 3, animated: animated)
            }
        } else {
            pickerView.selectRow(hourStartRow + hour, inComponent: 1, animated: animated)
        }
        
        let (_, minuteRemainder) = middleRow.quotientAndRemainder(dividingBy: 60)
        let minuteStartRow = middleRow - minuteRemainder
        pickerView.selectRow(minuteStartRow + (components.minute ?? 0), inComponent: 2, animated: animated)
    }


    private func titleForRow(_ row : Int, inComponentIndex componentIndex: Int) -> String {
        let normalizedRow = row - (BDTSDatePicker.maximumNumberOfRows / 2)
        
        if componentIndex == 0 {
            if normalizedRow == 0 {
                return "Today"
            } else {
                var components = DateComponents()
                components.day = normalizedRow
                let dateToDisplay = Calendar.current.date(byAdding: components, to: self.baseOffsetDate) ?? Date()
                let string = self.formatterForDateAndTimeMode.string(from: dateToDisplay)
                return string
            }
        } else if componentIndex == 1 {
            if BDTSDatePicker.hasAMPM {
                let (_, hour) = row.quotientAndRemainder(dividingBy: 12)
                if hour == 0 {
                    return "12"
                } else {
                    return String(describing: hour)
                }
            } else {
                let (_, hour) = row.quotientAndRemainder(dividingBy: 24)
                return String(describing: hour)
            }
        } else if componentIndex == 2 {
            let (_, minute) = row.quotientAndRemainder(dividingBy: 60)
            return String(format: "%02d", minute)
        } else if componentIndex == 3 {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")
            let symbols: [String] = [formatter.amSymbol, formatter.pmSymbol]
            return symbols[row]
        } else {
            fatalError()
        }
    }
    
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if BDTSDatePicker.hasAMPM {
            let hourRow = pickerView.selectedRow(inComponent: 1)
            let (_, hour) = hourRow.quotientAndRemainder(dividingBy: 24)
            if component == 3 {
                // User changed the AM/PM component, update the hours component if necessary
                if row == 0 && hour >= 12 {
                    pickerView.selectRow(hourRow - 12, inComponent: 1, animated: true)
                }
                if row == 1 && hour < 12 {
                    pickerView.selectRow(hourRow + 12, inComponent: 1, animated: true)
                }
            } else if component == 1 {
                // User changed the hour component, update the AM/PM component if necessary
                let ampmRow = pickerView.selectedRow(inComponent: 3)
                if hour >= 12 && ampmRow == 0 {
                    pickerView.selectRow(1, inComponent: 3, animated: true)
                } else if hour < 12 {
                    pickerView.selectRow(0, inComponent: 3, animated: true)
                }
            }
        }
        
        let hourRow = pickerView.selectedRow(inComponent: 1)
        let (_, hour) = hourRow.quotientAndRemainder(dividingBy: 24)
        let minuteRow = pickerView.selectedRow(inComponent: 2)
        let (_, minute) = minuteRow.quotientAndRemainder(dividingBy: 60)
        
        let dayNormalizedRow = pickerView.selectedRow(inComponent: 0) - (BDTSDatePicker.maximumNumberOfRows / 2)
        var dayComponent = DateComponents()
        dayComponent.day = dayNormalizedRow
        
        guard let calculatedDate = Calendar.current.date(byAdding: dayComponent, to: self.baseOffsetDate) else {
            self.date = Date.distantFuture
            return
        }
        
        var timeComponents = DateComponents()
        timeComponents.hour = hour
        timeComponents.minute = minute
        
        let startOfDay = Calendar.current.startOfDay(for: calculatedDate)
        if let newDate = Calendar.current.date(byAdding: timeComponents, to: startOfDay) {
            self.date = newDate
        } else {
            self.date = Date.distantFuture
        }
        self.onChange?()
    }
    
    public func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = view as? UILabel == nil ? UILabel() : view as! UILabel
        
        label.font = .preferredFont(forTextStyle: BDTSDatePicker.textStyle)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = BDTSDatePicker.textColor
        label.text = self.titleForRow(row, inComponentIndex: component)
        label.textAlignment = NSTextAlignment.right
        return label
    }
    
    public func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        let widthBuffer: CGFloat = 25.0
        let width: CGFloat
        
        if component == 0 {
            width = BDTSDatePicker.sizeForDynamicTypeLabelWithText("WWW WWW 99").width
        } else {
            width = BDTSDatePicker.sizeForNumericLabel(nDigits: 2).width
        }
        return width + widthBuffer
    }
    
    public func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        let size = BDTSDatePicker.sizeForDynamicTypeLabelWithText("99")
        return size.height
    }
}

fileprivate class DatePickerViewDelegate: BasePickerViewDelegate, UIPickerViewDelegate {
    public var minimumDate = Date.distantPast {
        didSet {
            self.validateMinimumAndMaximumDate()
        }
    }
    
    public var maximumDate = Date.distantFuture {
        didSet {
            self.validateMinimumAndMaximumDate()
        }
    }

    enum Components : Character  {
        case invalid = "!",
        year = "y",
        month = "M",
        day = "d"
    }
    
    internal func updatePickerViewComponentValues(_ pickerView: UIPickerView, _ animated: Bool) {
        for (_, dateComponent) in self.datePickerComponentOrdering.enumerated() {
            self.setIndexOfPickerView(pickerView, toComponent: dateComponent, animated: animated)
        }
    }
    
    internal func refreshComponentOrdering() {
        guard var componentOrdering = DateFormatter.dateFormat(fromTemplate: "yMMMMd", options: 0, locale: Locale.current) else {
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
    
    private func setIndexOfPickerView(_ pickerView: UIPickerView, toComponent component: Components, animated: Bool) {
        self.setIndexOfPickerView(pickerView, toComponent: component, toValue: self.valueForDateComponent(component), animated: animated)
    }
    
    private func setIndexOfPickerView(_ pickerView: UIPickerView, toComponent component: Components, toValue value : Int, animated: Bool) {
        let componentRange = self.maximumRangeForComponent(component)
        
        let idx = (value - componentRange.location)
        let middleIndex = (BDTSDatePicker.maximumNumberOfRows / 2) - (BDTSDatePicker.maximumNumberOfRows / 2) % componentRange.length + idx
        
        var componentIndex = 0
        
        for (index, dateComponent) in self.datePickerComponentOrdering.enumerated() {
            if (dateComponent == component) {
                componentIndex = index
            }
        }
        
        pickerView.selectRow(middleIndex, inComponent: componentIndex, animated: animated)
    }
    
    private func numberOfDaysForMonth(_ month : Int, inYear year : Int) -> Int {
        var components = DateComponents()
        components.month = month
        components.day = 1
        components.year = year
        
        let calendarRange = (Calendar.current as NSCalendar).range(of: .day, in: .month, for: Calendar.current.date(from: components)!)
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
    
    private func validateMinimumAndMaximumDate() {
        let ordering = self.minimumDate.compare(self.maximumDate)
        if (ordering != .orderedAscending ){
            fatalError("Cannot set a maximum date that is equal or less than the minimum date.")
        }
    }
    
    private func valueForDateComponent(_ component : Components) -> Int {
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
        
        return (Calendar.current as NSCalendar).maximumRange(of: calendarUnit)
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
        
        let dateForRow = Calendar.current.date(from: components)!
        
        return self.dateIsInRange(dateForRow)
    }
    
    private func dateIsInRange(_ date : Date) -> Bool {
        return self.minimumDate.compare(date) != ComparisonResult.orderedDescending &&
            self.maximumDate.compare(date) != ComparisonResult.orderedAscending
    }

    private var currentCalendarComponents : DateComponents {
        return (Calendar.current as NSCalendar).components([.year, .month, .day], from: self.date)
    }

    private var datePickerComponentOrdering = [Components]()
    private lazy var formatterForDateMode: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar.current
        dateFormatter.locale = Locale.current
        
        return dateFormatter
    }()
    
    private func componentAtIndex(_ index: Int) -> Components {
        return self.datePickerComponentOrdering[index]
    }

    private func titleForRow(_ row : Int, inComponentIndex componentIndex: Int) -> String {
        let dateComponent = self.componentAtIndex(componentIndex)
        
        let value = self.rawValueForRow(row, inComponent: dateComponent)
        
        if dateComponent == Components.month {
            let dateFormatter = self.formatterForDateMode
            return dateFormatter.monthSymbols[value - 1]
        } else {
            return String(value)
        }
    }

    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let datePickerComponent = self.componentAtIndex(component)
        let value = self.rawValueForRow(row, inComponent: datePickerComponent)
        
        // Create the newest valid date components.
        let components = self.validDateValueByUpdatingComponent(datePickerComponent, toValue: value)
        
        // If the resulting components are not in the date range ...
        if (!self.dateIsInRange(Calendar.current.date(from: components)!)) {
            // set to max
            self.date = self.maximumDate
        } else {
            // Get the components that would result by just force-updating the current components.
            let rawComponents = self.currentCalendarComponentsByUpdatingComponent(datePickerComponent, toValue: value)
            
            let day = components.day!
            
            if (rawComponents.day != components.day) {
                // Only animate the change if the day value is not a valid date.
                self.setIndexOfPickerView(pickerView, toComponent: .day, toValue: day, animated: self.isValidValue(day, forComponent: .day))
            }
            
            if (rawComponents.month != components.month) {
                self.setIndexOfPickerView(pickerView, toComponent: .month, toValue: day, animated: datePickerComponent != .month)
            }
            
            if (rawComponents.year != components.year) {
                self.setIndexOfPickerView(pickerView, toComponent: .year, toValue: day, animated: datePickerComponent != .year)
            }
            
            self.date = Calendar.current.date(from: components)!
        }
        self.onChange?()
    }
    
    public func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = view as? UILabel == nil ? UILabel() : view as! UILabel
        
        label.font = .preferredFont(forTextStyle: BDTSDatePicker.textStyle)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = BDTSDatePicker.textColor
        label.text = self.titleForRow(row, inComponentIndex: component)
        label.textAlignment = self.componentAtIndex(component) == .month ? NSTextAlignment.left : NSTextAlignment.right
        label.textColor = self.isRowEnabled(row, forComponent: self.componentAtIndex(component)) ? BDTSDatePicker.textColor : BDTSDatePicker.disabledTextColor
        return label
    }
    
    public func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        let widthBuffer: CGFloat = 25.0
        let calendarComponent = self.componentAtIndex(component)
        let size: CGFloat
        
        if calendarComponent == .month {
            
            // Get the length of the longest month string and set the size to it.
            var longest: CGFloat = 0.01
            for symbol in self.formatterForDateMode.monthSymbols as [String] {
                let monthSize = BDTSDatePicker.sizeForDynamicTypeLabelWithText(symbol)
                longest = max(longest, monthSize.width)
            }
            size = longest
        } else if calendarComponent == .day {
            size = BDTSDatePicker.sizeForNumericLabel(nDigits: 2).width
        } else if calendarComponent == .year {
            size = BDTSDatePicker.sizeForNumericLabel(nDigits: 4).width
        } else {
            fatalError()
        }
        
        // Add the width buffer in order to allow the picker components not to run up against the edges
        return size + widthBuffer
    }
    
    public func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        let size = BDTSDatePicker.sizeForDynamicTypeLabelWithText("99")
        return size.height
    }
}

