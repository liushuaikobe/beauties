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
        
        var longPressGenture = UILongPressGestureRecognizer(target: self, action: "onLongPress:")
        beautyImageView.addGestureRecognizer(longPressGenture)
        
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
    
    func onLongPress(sender: UILongPressGestureRecognizer) {
        if sender.state == .Began {
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
            
            let cancelAction = UIAlertAction(title: "取消", style: .Cancel, handler: nil)
            alertController.addAction(cancelAction)
            
            let saveAction = UIAlertAction(title: "保存", style: .Default, handler: {
                (action) -> Void in
                self.saveImage(forSharing: false)
            })
            alertController.addAction(saveAction)
            
            let shareAction = UIAlertAction(title: "分享", style: .Default, handler: {
                (action) -> Void in
                self.saveImage(forSharing: true)
            })
            alertController.addAction(shareAction)
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    func saveImage(#forSharing: Bool) {
        if let image = self.beautyImageView.image {
            
            let selector = forSharing ? Selector("saveImageFinishedForSharing:error:contextInfo:") : Selector("saveImageFinished:error:contextInfo:")
            
            UIImageWriteToSavedPhotosAlbum(image, self, selector, nil)
        }
    }
    
    func saveImageFinishedForSharing(image: UIImage, error: NSErrorPointer, contextInfo: UnsafePointer<()>) {
        var message = "图片已保存到相册，去分享吧 ლ(・∀・ )ლ"
        var OKTitle = "先这样"
        
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .Alert)
        
        if error != nil {
            println(error.memory)
            message = "保存失败 (#ﾟДﾟ)"
            OKTitle = "好吧"
        } else {
            let gotoWeChatAction = UIAlertAction(title: "直接分享到微信", style: .Default, handler: {
                (action) -> Void in
                UIApplication.sharedApplication().openURL(NSURL(string: "weixin://")!)
            })
            alertController.addAction(gotoWeChatAction)
        }
        
        let OKAction = UIAlertAction(title: OKTitle, style: .Default, handler: nil)
        alertController.addAction(OKAction)
        
        
        self.presentViewController(alertController, animated: true, completion: nil)
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

