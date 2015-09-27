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

    required init?(coder aDecoder: NSCoder) {
        imageView = UIImageView()
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.imageView.alpha = 0
    }
    
    func commonInit() -> Void {
        self.clipsToBounds = false
        self.layer.borderWidth = 10
        self.layer.borderColor = UIColor.whiteColor().CGColor
        self.layer.shadowColor = UIColor(red: 187 / 255.0, green: 187 / 255.0, blue: 187 / 255.0, alpha: 1).CGColor
        self.layer.shadowOpacity = 0.5
        self.layer.shadowOffset = CGSizeMake(2, 6)
        
        self.imageView.clipsToBounds = true
        self.imageView.frame = self.bounds
        self.imageView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        self.imageView.contentMode = .ScaleAspectFill
        self.addSubview(self.imageView)
    }
    
    func bindData(entity: BeautyImageEntity) -> Void {
        
        if let urlString = entity.imageUrl {
            if let url = NSURL(string: urlString) {
                self.imageView.kf_setImageWithURL(url, placeholderImage: nil, optionsInfo: nil, completionHandler: {
                    [weak self](image, error, cacheType, imageURL) -> () in
                    UIView.animateWithDuration(0.5, delay: 0, options: .CurveEaseIn, animations: { () -> Void in
                        self?.imageView.alpha = 1
                        }, completion: nil)
                })
            }
        }
    }
}