//
//  BeautyCollectionViewCell.swift
//  beauties
//
//  Created by Shuai Liu on 15/7/1.
//  Copyright (c) 2015年 Shuai Liu. All rights reserved.
//

import Foundation
import UIKit

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
        clipsToBounds = false
        layer.borderWidth = 20
        layer.borderColor = UIColor.whiteColor().CGColor
    }
    
    func bindData(entity: BeautyImageEntity) -> Void {
        
    }
}