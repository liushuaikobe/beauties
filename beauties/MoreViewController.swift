//
//  MoreViewController.swift
//  beauties
//
//  Created by Shuai Liu on 15/8/3.
//  Copyright (c) 2015年 Shuai Liu. All rights reserved.
//

import Foundation
import UIKit

class MoreViewController: UITableViewController {
    
    var logoImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.tableFooterView = UIView()
        
        logoImage = UIImageView(image: UIImage(named: "logo.png"))
        logoImage.backgroundColor = UIColor.clearColor()
        logoImage.contentMode = .ScaleAspectFit
        self.view.addSubview(logoImage)
        self.view.bringSubviewToFront(logoImage)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        logoImage.center = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetHeight(self.view.bounds) - 200 - CGRectGetMinY(logoImage.bounds))
        var frame = logoImage.frame
        frame.size = CGSizeMake(120, 110)
        logoImage.frame = frame
    }
}