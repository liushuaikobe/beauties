//
//  BeautyCollectionViewCell.swift
//  beauties
//
//  Created by Shuai Liu on 15/7/1.
//  Copyright (c) 2015年 Shuai Liu. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher

class BeautyCollectionViewCell: UICollectionViewCell {
    
    var imageView: UIImageView
    
    override init(frame: CGRect) {
        imageView = UIImageView()
        super.init(frame: frame)
        commonInit()
    }

    required init(coder aDecoder: NSCoder) {
        imageView = UIImageView()
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() -> Void {
        self.clipsToBounds = false
        self.layer.borderWidth = 10
        self.layer.borderColor = UIColor.whiteColor().CGColor
        self.layer.shadowColor = UIColor(red: 187 / 255.0, green: 187 / 255.0, blue: 187 / 255.0, alpha: 1).CGColor
        self.layer.shadowOpacity = 0.5
        self.layer.shadowOffset = CGSizeMake(2, 6)
        
        self.imageView.clipsToBounds = true
        self.addSubview(self.imageView)
    }
    
    func bindData(entity: BeautyImageEntity) -> Void {
        self.imageView.frame = self.bounds
        self.imageView.contentMode = .ScaleAspectFill
        if let urlString = entity.imageUrl {
            if let url = NSURL(string: urlString) {
                self.imageView.kf_setImageWithURL(url)
            }
        }
    }
}