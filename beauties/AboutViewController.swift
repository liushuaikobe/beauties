//
//  AboutViewController.swift
//  beauties
//
//  Created by Shuai Liu on 15/8/6.
//  Copyright (c) 2015年 Shuai Liu. All rights reserved.
//

import Foundation
import UIKit

class AboutViewController: UIViewController {
    @IBOutlet weak var linkLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        linkLabel.textColor = UIColor(red: 65.0 / 255.0, green: 131.0 / 255.0, blue: 196.0 / 255.0, alpha: 1)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: "gotoURL")
        linkLabel.addGestureRecognizer(tapGesture)
    }
    
    func gotoURL() {
        let url = NSURL(string: linkLabel.text!)!
        UIApplication.sharedApplication().openURL(url)
    }
}