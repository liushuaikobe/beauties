//
//  Utils.swift
//  beauties
//
//  Created by Shuai Liu on 15/7/4.
//  Copyright (c) 2015年 Shuai Liu. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

let ThemeColor = UIColor(red: 222.0 / 255.0, green: 110.0 / 255.0, blue: 75.0 / 255.0, alpha: 1)

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
    static let API_DATA_URL = "http://gank.avosapps.com/api/data/%E7%A6%8F%E5%88%A9/"
    static let API_DAY_URL  = "http://gank.avosapps.com/api/day/"
    
    static let PAGE_SIZE = 20
    
    class func getBeauties(page: Int, complete: ([String], NSError?) -> Void) {
        
        let url = "\(API_DATA_URL)\(PAGE_SIZE)/\(page)"
        
        println(url)
        
        Alamofire.request(.GET, url).responseJSON {
            _, _, json, error in
            
            if error != nil {
                println("ERROR: \(error?.localizedDescription)")
                complete([String](), error)
                return
            }
            
            if let j = json as? Dictionary<String, AnyObject> {
                
                if let results = j["results"] as? [Dictionary<String, AnyObject>] {
                    
                    var ret = [String]()
                    
                    for b in results {
                        ret.append(b["url"] as! String)
                    }
                    
                    complete(ret, nil)
                    return
                }
                
            }
            
            complete([String](), nil)
        }
    }
    
    class func getTodayBeauty(complete: [String] -> Void) {
        
        println(API_DAY_URL + BeautyDateUtil.todayString())
        
        Alamofire.request(.GET, API_DAY_URL + BeautyDateUtil.todayString()).responseJSON {
            _, _, json, error in
            
            if error != nil {
                println("ERROR: \(error?.localizedDescription)")
                complete([String]())
                return
            }
            
            if let j = json as? Dictionary<String, AnyObject> {
                
                if let category = j["category"] as? [String] {
                    
                    if contains(category, "福利") {
                        
                        if let results = j["results"] as? Dictionary<String, AnyObject> {
                            
                            if let fulis = results["福利"] as? [Dictionary<String, AnyObject>] {
                                
                                var ret = Array<String>()
                                
                                for fuli in fulis {
                                    ret.append(fuli["url"] as! String)
                                }
                                
                                complete(ret)
                                return
                            }
                        }
                    }
                }
            }
            complete([String]())
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