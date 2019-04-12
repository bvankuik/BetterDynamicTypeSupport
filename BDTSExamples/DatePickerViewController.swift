//
//  DatePickerViewController.swift
//  BDTSExamples
//
//  Created by Bart van Kuik on 10/04/2019.
//  Copyright © 2019 DutchVirtual. All rights reserved.
//

import UIKit
import BetterDynamicTypeSupport

class DatePickerViewController: UIViewController {
    @IBOutlet weak var datePicker: BDTSDatePicker!
    @IBOutlet weak var label: UILabel!

    let validPast: TimeInterval = -10000000000
    
    @objc func datePickerValueChanged() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .long
        self.label.text = dateFormatter.string(from: self.datePicker.date)
    }
    
    override func viewDidLoad() {
        self.navigationItem.title = "Date picker"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.datePicker.minimumDate = Date().addingTimeInterval(validPast)
        self.datePicker.setDate(Date(), animated: false)
        self.datePicker.mode = .dateAndTime
        self.datePicker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
    }
}
