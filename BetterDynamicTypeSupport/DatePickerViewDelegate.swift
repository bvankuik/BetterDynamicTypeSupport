//
//  DatePickerViewDelegate.swift
//  BetterDynamicTypeSupport
//
//  Created by Bart van Kuik on 15/04/2019.
//  Copyright © 2019 DutchVirtual. All rights reserved.
//

import UIKit

class DatePickerViewDelegate: BaseDatePickerViewDelegate, UIPickerViewDelegate {
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
                let monthSize = self.sizeForDynamicTypeLabelWithText(symbol)
                longest = max(longest, monthSize.width)
            }
            size = longest
        } else if calendarComponent == .day {
            size = self.sizeForDynamicTypeLabelWithText("99").width
        } else if calendarComponent == .year {
            size = self.sizeForDynamicTypeLabelWithText("9999").width
        } else {
            fatalError()
        }
        
        // Add the width buffer in order to allow the picker components not to run up against the edges
        return size + widthBuffer
    }
    
    public func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        let size = self.sizeForDynamicTypeLabelWithText("99")
        return size.height
    }
}
