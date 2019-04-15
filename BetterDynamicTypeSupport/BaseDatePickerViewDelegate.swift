//
//  BaseDatePickerViewDelegate.swift
//  BetterDynamicTypeSupport
//
//  Created by Bart van Kuik on 15/04/2019.
//  Copyright © 2019 DutchVirtual. All rights reserved.
//

import Foundation

class BaseDatePickerViewDelegate: NSObject {
    let baseOffsetDate = Date()
    var date = Date()
    var onChange: (() -> Void)?
    private let labelForSizeMeasurement = UILabel()

    func sizeForDynamicTypeLabelWithText(_ text: String) -> CGSize {
        labelForSizeMeasurement.text = text
        labelForSizeMeasurement.font = .preferredFont(forTextStyle: BDTSDatePicker.textStyle)
        labelForSizeMeasurement.adjustsFontForContentSizeCategory = true
        
        let size = labelForSizeMeasurement.systemLayoutSizeFitting(.zero)
        return size
    }
}
