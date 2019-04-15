//
//  DateAndTimePickerViewDelegate.swift
//  BetterDynamicTypeSupport
//
//  Created by Bart van Kuik on 15/04/2019.
//  Copyright © 2019 DutchVirtual. All rights reserved.
//

import UIKit

class DateAndTimePickerViewDelegate: BaseDatePickerViewDelegate, UIPickerViewDelegate {
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
        if Locale.current.hasAMPM {
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
            if Locale.current.hasAMPM {
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
        if Locale.current.hasAMPM {
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
            width = self.sizeForDynamicTypeLabelWithText("WWW WWW 99").width
        } else {
            width = self.sizeForDynamicTypeLabelWithText("99").width
        }
        return width + widthBuffer
    }
    
    public func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        let size = self.sizeForDynamicTypeLabelWithText("99")
        return size.height
    }
}



