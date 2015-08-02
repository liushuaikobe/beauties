//
//  ViewController.swift
//  beauties
//
//  Created by Shuai Liu on 15/6/27.
//  Copyright (c) 2015年 Shuai Liu. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import Kingfisher

class TodayViewController: UIViewController {

    var beautyImageView: UIImageView!
    
    var todayBeauty: BeautyImageEntity?
    var canBeClosed: Bool
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        canBeClosed = false
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init(coder aDecoder: NSCoder) {
        canBeClosed = false
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        beautyImageView = UIImageView()
        beautyImageView.userInteractionEnabled = true
        beautyImageView.layer.borderColor = UIColor.whiteColor().CGColor
        beautyImageView.layer.borderWidth = 10
        beautyImageView.layer.shadowOpacity = 0.5
        beautyImageView.layer.shadowColor = UIColor(red: 187 / 255.0, green: 187 / 255.0, blue: 187 / 255.0, alpha: 1).CGColor
        beautyImageView.layer.shadowOffset = CGSizeMake(2, 6)
        self.view.addSubview(beautyImageView)
        
        if canBeClosed {
            var swipeGesture = UISwipeGestureRecognizer(target: self, action: "onSwipe:")
            swipeGesture.direction = UISwipeGestureRecognizerDirection.Down
            beautyImageView.addGestureRecognizer(swipeGesture)
        }
        
        var setImage: BeautyImageEntity -> Void = {
            if let imageURLString = $0.imageUrl {
                if let imageURL = NSURL(string: imageURLString) {
                    self.beautyImageView.kf_setImageWithURL(imageURL, placeholderImage: nil, optionsInfo: nil) {
                        (image, error, cacheType, imageURL) -> () in
                        if image != nil {
                            var bgi = UIImageView(image: image!)
                            bgi.contentMode = .ScaleToFill
                            bgi.frame = self.view.bounds
                            self.view.addSubview(bgi)
                            self.view.sendSubviewToBack(bgi)
                            bgi.applyBlurEffect()
                        }
                    }
                    self.view.setNeedsLayout()
                }
            }
        };
        
        if todayBeauty != nil {
            setImage(todayBeauty!)
            return
        }
        
        NetworkUtil.getTodayImage() {
            beautyEntity in
            self.todayBeauty = beautyEntity
            if beautyEntity != nil {
                setImage(beautyEntity!)
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let maxHeight = Int(self.view.bounds.height) - 100
        let maxWidth = Int(self.view.bounds.width) - 40
        
        if self.todayBeauty != nil {
            var preferWidth = maxWidth
            var preferHeight = Int(preferWidth * self.todayBeauty!.imageHeight! / self.todayBeauty!.imageWidth!)
            
            if preferHeight > maxHeight {
                preferHeight = maxHeight
                preferWidth = Int(preferHeight * self.todayBeauty!.imageWidth! / self.todayBeauty!.imageHeight!)
            }
            
            self.beautyImageView.frame = CGRect(origin: CGPointZero, size: CGSize(width: preferWidth, height: preferHeight))
        }
        self.beautyImageView.center = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds) - 50)
    }

    func onSwipe(sender: UISwipeGestureRecognizer) {
        if canBeClosed {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

