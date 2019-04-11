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
    
    override func viewDidLoad() {
        self.navigationItem.title = "Date picker"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.datePicker.minimumDate = Date().addingTimeInterval(validPast)
        self.datePicker.delegate = self
    }
    
    @IBAction func randomizeColor(_ sender: UIButton) {
        let red = CGFloat(arc4random_uniform(255))
        let green = CGFloat(arc4random_uniform(255))
        let blue = CGFloat(arc4random_uniform(255))
        
        self.datePicker.textColor = UIColor(red: red/255, green: green/255, blue: blue/255, alpha: 1)
        self.datePicker.reloadAllComponents()
    }
    
    @IBAction func randomizeFont(_ sender: UIButton) {
        var fontName: String? = nil
        
        while fontName == nil {
            let familyNames = UIFont.familyNames
            let randomNumber = Int(arc4random_uniform(UInt32(familyNames.count)))
            let familyName: String = familyNames[randomNumber]
            if let name: String = UIFont.fontNames(forFamilyName: familyName).first {
                fontName = name
            }
        }
        
        self.datePicker.font = UIFont(name: fontName!, size: 14)!
        self.datePicker.reloadAllComponents()
    }
}

extension DatePickerViewController: BDTSDatePickerDelegate {
    func pickerView(_ pickerView: BDTSDatePicker, didSelectRow row: Int, inComponent component: Int) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        self.label.text = dateFormatter.string(from: pickerView.date)
    }
}
