//
//  MenuViewController.swift
//  BDTSExamples
//
//  Created by Bart van Kuik on 12/04/2019.
//  Copyright © 2019 DutchVirtual. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController {
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Skipping the first screen us useful for manual testing
//        self.performSegue(withIdentifier: "Test date picker", sender: nil)
    }
}
