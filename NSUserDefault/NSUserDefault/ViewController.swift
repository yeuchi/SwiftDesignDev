//
//  ViewController.swift
//  NSUserDefault
//
//  Created by yeuchi on 6/13/20.
//  Copyright © 2020 yeuchi. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var txtTime: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateDateLabel()
        // Do any additional setup after loading the view.
    }

    @IBAction func onClickButton(_ sender: UIButton) {
        let now = NSDate()
        UserDefaults.standard.set(now, forKey: "buttonTapped")
        self.updateDateLabel()
    }
    
    func updateDateLabel() {
        let lastUpdate = UserDefaults.standard.object(forKey: "buttonTapped") as? NSDate
        if let hasLastUpdate = lastUpdate {
            self.txtTime.text = hasLastUpdate.description
        }
        else {
            self.txtTime.text = "No date saved."
        }
    }
}

