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
    
    static let PAGE_SIZE = 20
    static let API_FORMAT = "yyyy/MM/dd"
    static let MAX_PAGE = 5
    
    class func generateHistoryDateString(page: Int) -> [String] {
        return self.generateHistoryDateString(format: self.API_FORMAT, historyCount: self.PAGE_SIZE, page: page)
    }
    
    class func generateHistoryDateString(#format: String, historyCount: Int, page: Int) -> [String] {
        
        let today = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let formatter = NSDateFormatter()
        formatter.dateFormat = format
        
        let unit = ((page - 1) * self.PAGE_SIZE)...(page * self.PAGE_SIZE - 1)
        return unit.map({calendar.dateByAddingUnit(.CalendarUnitDay, value: -$0, toDate: today, options: nil)}).filter({$0 != nil}).map({formatter.stringFromDate($0!)})
    }
    
    class func todayString() -> String {
        let today = NSDate()
        let formatter = NSDateFormatter()
        formatter.dateFormat = self.API_FORMAT
        return formatter.stringFromDate(today)
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
    
    class func getImageByDateSync(date: String) -> BeautyImageEntity? {
        
        if let entity = DataUtil.findBeautyForDate(date) {
            println("Hit Cache for date: \(date)!")
            return entity
        }
        
        let url = NSURL(string: API + date)!
        var request = NSURLRequest(URL: url)
        var response: AutoreleasingUnsafeMutablePointer<NSURLResponse? >= nil
        var error: NSErrorPointer = nil
        var data = NSURLConnection.sendSynchronousRequest(request, returningResponse: response, error: error)
        
//        if error.memory != nil {
//            return nil
//        }
        
        if let htmlContentData = data {
            let htmlContent = NSString(data: htmlContentData, encoding: NSUTF8StringEncoding) as! String
            var entity = self.getImageEntityFromHTML(htmlContent)
            if entity != nil {
                DataUtil.saveBeauty(entity!, forDate: date)
            }
            return entity
        } else {
            return nil
        }
    }
    
    class func getImageByDate(date: String, complete: (BeautyImageEntity?) -> Void) -> Void {
        
        if let entity = DataUtil.findBeautyForDate(date) {
            println("Hit Cache for date: \(date)!")
            complete(entity)
            return
        }
        
        Alamofire.request(.GET, API + date).responseString(encoding: NSUTF8StringEncoding) {
            (request, response, str, error) -> Void in
            // ERROR
            if error != nil {
                println(error)
                complete(nil)
                return
            }
            
            if let htmlContent = str {
                
                let beautyImageEntity = self.getImageEntityFromHTML(htmlContent)
                
                if beautyImageEntity != nil {
                    DataUtil.saveBeauty(beautyImageEntity!, forDate: date)
                }
                
                complete(beautyImageEntity)
            }
        }
    }
    
    class func getImageEntityFromHTML(htmlContent: String) -> BeautyImageEntity? {
        var beautyImageEntity = BeautyImageEntity()
        
        let matches = self.regex.matchesInString(htmlContent, options: nil, range: NSMakeRange(0, count(htmlContent)))
        
        if count(matches) == 0 {
            return nil
        }
        
        let match = (matches as! [NSTextCheckingResult])[0]
        
        // ------------- get image url
        let beautyUrl = (htmlContent as NSString).substringWithRange(match.rangeAtIndex(1))
        beautyImageEntity.imageUrl = beautyUrl
        
        // ------------- get width and height
        let style = (htmlContent as NSString).substringWithRange(match.rangeAtIndex(2))
        
        let heightMatches = self.heightRegex.matchesInString(style, options: nil, range: NSMakeRange(0, count(style)))
        let widthMatches = self.widthRegex.matchesInString(style, options: nil, range: NSMakeRange(0, count(style)))
        
        if count(heightMatches) > 0 {
            let heightMatch = (heightMatches as! [NSTextCheckingResult])[0]
            beautyImageEntity.imageHeight = (style as NSString).substringWithRange(heightMatch.rangeAtIndex(1)).toInt()
        }
        if count(widthMatches) > 0 {
            let widthMatch = (widthMatches as! [NSTextCheckingResult])[0]
            beautyImageEntity.imageWidth = (style as NSString).substringWithRange(widthMatch.rangeAtIndex(1)).toInt()
        }
        
        return beautyImageEntity
    }
    
    class func getTodayImage(complete: (BeautyImageEntity?) -> Void) -> Void {
        let todayDateStr = BeautyDateUtil.todayString()
        self.getImageByDate(todayDateStr) {
            entity in
            if entity == nil {
                if let cachedEntity = DataUtil.getLatestEntity() {
                    complete(cachedEntity)
                } else {
                    // default image
                    println("No beauty online, no cache neither. Return default beauty")
                    let defaultEntity = BeautyImageEntity()
                    defaultEntity.imageUrl = "http://ww4.sinaimg.cn/large/7a8aed7bgw1etv4ehu391j20f00migoi.jpg"
                    defaultEntity.imageHeight = 825
                    defaultEntity.imageWidth = 550
                    complete(defaultEntity)
                }
            } else {
                complete(entity)
            }
        }
    }
    
}

class DataUtil {
    private static let fileName = "data.dat"
    private static var haveReadCache = false
    private static var beautiesCache = [String: BeautyImageEntity]()
    
    
    class func saveBeauty(beauty: BeautyImageEntity, forDate date: String) {
        println("Save Entity(\(beauty)) for \(date)")
        beautiesCache[date] = beauty
    }
    
    class func findBeautyForDate(date: String) -> BeautyImageEntity? {
        if !self.haveReadCache {
            self.haveReadCache = true
            self.readCacheFromFile()
        }
        return self.beautiesCache[date]
    }
    
    class func deleteBeautyForDate(date: String) {
        beautiesCache.removeValueForKey(date)
    }
    
    class func getLatestEntity() -> BeautyImageEntity? {
        let cachedDates = self.beautiesCache.keys.array
        
        if count(cachedDates) != 0 {
            let latestDateStr = maxElement(cachedDates)
            println("Get Latest cached entity, the Latest Date: \(latestDateStr)")
            return self.beautiesCache[maxElement(cachedDates)]!
        } else {
            return nil
        }
    }
    
    private class func buildFilePathWithName(name: String) -> String {
        let manager = NSFileManager.defaultManager()
        let dirUrl = manager.URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: false, error: nil)
        return dirUrl!.URLByAppendingPathComponent(name).path!
    }
    
    class func writeCacheToFile() {
        println("Write Cache into file.")
        let filePath = self.buildFilePathWithName(self.fileName)
        NSKeyedArchiver.archiveRootObject(self.beautiesCache, toFile: filePath)
    }
    
    class func readCacheFromFile() {
        println("Read Cache from file")
        let filePath = self.buildFilePathWithName(self.fileName)
        
        if let cache = NSKeyedUnarchiver.unarchiveObjectWithFile(filePath) as? [String: BeautyImageEntity] {
            self.beautiesCache = cache
        }
    }
}