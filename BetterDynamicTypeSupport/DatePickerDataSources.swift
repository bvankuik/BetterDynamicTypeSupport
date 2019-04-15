//
//  DateAndTimeDataSource.swift
//  BetterDynamicTypeSupport
//
//  Created by Bart van Kuik on 15/04/2019.
//  Copyright © 2019 DutchVirtual. All rights reserved.
//

import UIKit

class DateAndTimeDataSource: NSObject, UIPickerViewDataSource {
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 3 {
            return 2
        } else {
            return BDTSDatePicker.maximumNumberOfRows
        }
    }
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return (Locale.current.hasAMPM ? 4 : 3)
    }
}

class DateDataSource: NSObject, UIPickerViewDataSource {
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return BDTSDatePicker.maximumNumberOfRows
    }
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
}
