//
//  Locale+Extensions.swift
//  BetterDynamicTypeSupport
//
//  Created by Bart van Kuik on 15/04/2019.
//  Copyright © 2019 DutchVirtual. All rights reserved.
//

import Foundation

extension Locale {
    var hasAMPM: Bool {
        let formatString: String = DateFormatter.dateFormat(fromTemplate: "j", options: 0, locale: self)!
        return formatString.contains("a")
    }
}
