//
//  Utils.swift
//  beauties
//
//  Created by Shuai Liu on 15/7/4.
//  Copyright (c) 2015年 Shuai Liu. All rights reserved.
//

import Foundation
import Alamofire

class BeautyDateUtil {
    
    static let PAGE_SIZE = 20;
    static let API_FORMAT = "yyyy/MM/dd"
    
    class func generateHistoryDateString(#format: String, historyCount: Int) -> [String] {
        
        let today = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let formatter = NSDateFormatter()
        formatter.dateFormat = format
        
        var result: [String] = []
        
        // TODO: rewite with map
        
        for i in 0...historyCount {
            let nDaysAgo = calendar.dateByAddingUnit(.CalendarUnitDay, value: -i, toDate: today, options: nil)
            if nDaysAgo != nil {
                result.append(formatter.stringFromDate(nDaysAgo!))
            }
        }
        
        return result
    }
}

class NetworkUtil {
    static let API = "http://gank.io/"
    
    static let patternString = "<img\\s+alt=\".*\"\\s+src=\"(.+)\"\\s+style=\"(.*)\"\\s*/>"
    static let regex = NSRegularExpression(pattern: patternString, options: .CaseInsensitive, error: nil)!
    
    static let heightPatternString = "height\\s*:\\s*(\\d+)px"
    static let heightRegex = NSRegularExpression(pattern: heightPatternString, options: .CaseInsensitive, error: nil)!
    static let widthPatterString = "width\\s*:\\s*(\\d+)px"
    static let widthRegex = NSRegularExpression(pattern: widthPatterString, options: .CaseInsensitive, error: nil)!
    
    class func getImageByDate(date: String, complete: (BeautyImageEntity?) -> Void) -> Void {
        Alamofire.request(.GET, API + date).responseString(encoding: NSUTF8StringEncoding) {
            (request, response, str, error) -> Void in
            // ERROR
            if error != nil {
                println(error)
                complete(nil)
                return
            }
            
            if let htmlContent = str {
                
                var beautyImageEntity = BeautyImageEntity()
                
                
                let matches = self.regex.matchesInString(htmlContent, options: nil, range: NSMakeRange(0, count(htmlContent)))
                
                if count(matches) == 0 {
                    complete(nil)
                    return
                }
                
                let match = (matches as! [NSTextCheckingResult])[0]
                
                // ------------- get image url
                let beautyUrl = (htmlContent as NSString).substringWithRange(match.rangeAtIndex(1))
                beautyImageEntity.imageUrl = beautyUrl
                
                // ------------- get width and height
                let style = (htmlContent as NSString).substringWithRange(match.rangeAtIndex(2))
                
                let heightMatches = self.heightRegex.matchesInString(style, options: nil, range: NSMakeRange(0, count(style)))
                let widthMatches = self.widthRegex.matchesInString(style, options: nil, range: NSMakeRange(0, count(style)))
                
                // TODO: check if style exists
                
                let heightMatch = (heightMatches as! [NSTextCheckingResult])[0]
                beautyImageEntity.imageHeight = (style as NSString).substringWithRange(heightMatch.rangeAtIndex(1)).toInt()
                let widthMatch = (widthMatches as! [NSTextCheckingResult])[0]
                beautyImageEntity.imageWidth = (style as NSString).substringWithRange(widthMatch.rangeAtIndex(1)).toInt()
                
                complete(beautyImageEntity)
            }
        }
    }
    
    class func getTodayImage(complete: (BeautyImageEntity?) -> Void) -> Void {
        self.getImageByDate("", complete: complete)
    }
    
}