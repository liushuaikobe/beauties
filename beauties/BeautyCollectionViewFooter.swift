//
//  BeautyCollectionViewFooter.swift
//  beauties
//
//  Created by Shuai Liu on 15/8/5.
//  Copyright (c) 2015年 Shuai Liu. All rights reserved.
//

import Foundation
import UIKit

class BeautyCollectionViewFooter: UICollectionReusableView {
    
    var loadingIndicator: UIActivityIndicatorView
    
    override init(frame: CGRect) {
        loadingIndicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init(coder aDecoder: NSCoder) {
        loadingIndicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    private func commonInit() {
        self.addSubview(loadingIndicator)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.loadingIndicator.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds))
    }
    
    func startAnimating() {
        self.loadingIndicator.startAnimating()
    }
    
    func stopAnimating() {
        self.loadingIndicator.stopAnimating()
    }
}