//
//  ViewController.swift
//  beauties
//
//  Created by Shuai Liu on 15/6/27.
//  Copyright (c) 2015年 Shuai Liu. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher

class TodayViewController: UIViewController {

    var beautyImageView: UIImageView!
    var loadingIndicator: UIActivityIndicatorView!
    
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
        self.view.backgroundColor = ThemeColor
        
        loadingIndicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        loadingIndicator.hidesWhenStopped = true
        self.view.addSubview(loadingIndicator)
        loadingIndicator.startAnimating()
        
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
        
        var longPressGenture = UILongPressGestureRecognizer(target: self, action: "onLongPress:")
        beautyImageView.addGestureRecognizer(longPressGenture)
        
        var setImage: BeautyImageEntity -> Void = {
            if let imageURLString = $0.imageUrl {
                if let imageURL = NSURL(string: imageURLString) {
                    self.beautyImageView.alpha = 0
                    KingfisherManager.sharedManager.retrieveImageWithURL(imageURL, optionsInfo: nil, progressBlock: nil, completionHandler: {
                        [weak self](image, error, cacheType, imageURL) -> () in
                        self?.loadingIndicator.stopAnimating()
                        if let beauty = image {
                            self?.beautyImageView.image = beauty
                            self?.setBackgroundImage(beauty)
                            UIView.animateWithDuration(0.7, delay: 0, options: .CurveEaseIn, animations: {
                                self?.beautyImageView.alpha = 1
                            }, completion: nil)
                        }
                        self?.view.setNeedsLayout()
                    })
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if (loadingIndicator.isAnimating()) {
            loadingIndicator.center = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds))
        }
        
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
    
    func onLongPress(sender: UILongPressGestureRecognizer) {
        if sender.state == .Began {
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
            
            let cancelAction = UIAlertAction(title: "取消", style: .Cancel, handler: nil)
            alertController.addAction(cancelAction)
            
            let saveAction = UIAlertAction(title: "保存", style: .Default, handler: {
                (action) -> Void in
                self.saveImage()
            })
            alertController.addAction(saveAction)
            
            let shareAction = UIAlertAction(title: "分享", style: .Default, handler: {
                (action) -> Void in
                self.shareImage()
            })
            alertController.addAction(shareAction)
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    func setBackgroundImage(image: UIImage) {
        var bgi = UIImageView(image: image)
        bgi.contentMode = .ScaleToFill
        bgi.frame = self.view.bounds
        self.view.addSubview(bgi)
        self.view.sendSubviewToBack(bgi)
        bgi.applyBlurEffect()
    }
    
    func saveImage() {
        if let image = self.beautyImageView.image {
            UIImageWriteToSavedPhotosAlbum(image, self, Selector("saveImageFinished:error:contextInfo:"), nil)
        }
    }
    
    func shareImage() {
        if let image = self.beautyImageView.image {
            var text = "分享漂亮妹纸一枚~"
            var activityController = UIActivityViewController(activityItems: [text, image], applicationActivities: nil)
            [self .presentViewController(activityController, animated: true, completion: nil)]
        }
    }
    
    func saveImageFinished(image: UIImage, error: NSErrorPointer, contextInfo: UnsafePointer<()>) {
        var message = "保存成功 (ฅ´ω`ฅ)"
        var OKTitle = "好的"
        if error != nil {
            println(error.memory)
            message = "保存失败 (´◔ ‸◔')"
            OKTitle = "好吧"
        }
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .Alert)
        
        let OKAction = UIAlertAction(title: OKTitle, style: .Default, handler: nil)
        alertController.addAction(OKAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
}

