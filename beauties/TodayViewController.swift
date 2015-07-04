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

    var beautyImageView: UIImageView?
    
    var todayBeauty: BeautyImageEntity?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        beautyImageView = UIImageView()
        beautyImageView!.layer.borderColor = UIColor.whiteColor().CGColor
        beautyImageView!.layer.borderWidth = 10
        beautyImageView!.layer.shadowOpacity = 0.5
        beautyImageView!.layer.shadowColor = UIColor(red: 187 / 255.0, green: 187 / 255.0, blue: 187 / 255.0, alpha: 1).CGColor
        beautyImageView!.layer.shadowOffset = CGSizeMake(2, 6)
        self.view.addSubview(beautyImageView!)
        
        Alamofire.request(.GET, "http://gank.io/").responseString(encoding: NSUTF8StringEncoding) {
            (request, response, str, error) -> Void in
            // TODO: check error
            if let htmlContent = str {
                // TODO: check circular reference
                self.todayBeauty = BeautyImageEntity()
                
                let patternString = "<img\\s+alt=\".*\"\\s+src=\"(.+)\"\\s+style=\"(.*)\"\\s*/>"
                let regex = NSRegularExpression(pattern: patternString, options: .CaseInsensitive, error: nil)!
                let matches = regex.matchesInString(htmlContent, options: nil, range: NSMakeRange(0, count(htmlContent)))
                
                let match = (matches as! [NSTextCheckingResult])[0]
                
                // ------------- get image url
                let beautyUrl = (htmlContent as NSString).substringWithRange(match.rangeAtIndex(1))
                
                self.todayBeauty!.imageUrl = beautyUrl
                
                // ------------- get width and height
                let style = (htmlContent as NSString).substringWithRange(match.rangeAtIndex(2))
                
                let heightPatternString = "height\\s*:\\s*(\\d+)px"
                let widthPatterString = "width\\s*:\\s*(\\d+)px"
                
                let heightRegex = NSRegularExpression(pattern: heightPatternString, options: .CaseInsensitive, error: nil)!
                let widthRegex = NSRegularExpression(pattern: widthPatterString, options: .CaseInsensitive, error: nil)!
                
                let heightMatches = heightRegex.matchesInString(style, options: nil, range: NSMakeRange(0, count(style)))
                let widthMatches = widthRegex.matchesInString(style, options: nil, range: NSMakeRange(0, count(style)))
                
                let heightMatch = (heightMatches as! [NSTextCheckingResult])[0]
                self.todayBeauty!.imageHeight = (style as NSString).substringWithRange(heightMatch.rangeAtIndex(1)).toInt()
                let widthMatch = (widthMatches as! [NSTextCheckingResult])[0]
                self.todayBeauty!.imageWidth = (style as NSString).substringWithRange(widthMatch.rangeAtIndex(1)).toInt()
                
                self.beautyImageView!.kf_setImageWithURL(NSURL(string: self.todayBeauty!.imageUrl!)!, placeholderImage: nil, optionsInfo: nil) { (image, error, cacheType, imageURL) -> () in
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
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
//        self.view.layer.borderColor = UIColor.redColor().CGColor
//        self.view.layer.borderWidth = 1.0
        
        let maxHeight = Int(self.view.bounds.height) - 100
        let maxWidth = Int(self.view.bounds.width) - 40
        
        if self.todayBeauty != nil {
            
            var preferWidth = maxWidth
            
            var preferHeight = Int(preferWidth * self.todayBeauty!.imageHeight! / self.todayBeauty!.imageWidth!)
            
            if preferHeight > maxHeight {
                preferHeight = maxHeight
                preferWidth = Int(preferHeight * self.todayBeauty!.imageWidth! / self.todayBeauty!.imageHeight!)
            }
            
            self.beautyImageView!.frame = CGRect(origin: CGPointZero, size: CGSize(width: preferWidth, height: preferHeight))
        }
        
        self.beautyImageView!.center = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds) - 50)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

