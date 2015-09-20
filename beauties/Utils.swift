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
    static let API_RANDOM_URL = "http://gank.avosapps.com/api/random/data/%E7%A6%8F%E5%88%A9/"
    
    static let PAGE_SIZE = 20
    
    class func getBeauties(page: Int, complete: ([String], NSError?) -> Void) {

        let url = "\(API_DATA_URL)\(PAGE_SIZE)/\(page)"
#if DEBUG
        println(url)
#endif
        Alamofire.request(.GET, url).responseJSON {
            _, _, json, error in
            
            if NetworkUtil.error(error) {
                complete([String](), error)
                return
            }
            
            complete(NetworkUtil.parseBeautyList(json), nil)
        }
    }
    
    class func getTodayBeauty(complete: [String] -> Void) {
#if DEBUG
        println(API_DAY_URL + BeautyDateUtil.todayString())
#endif
        Alamofire.request(.GET, API_DAY_URL + BeautyDateUtil.todayString()).responseJSON {
            _, _, json, error in
            
            if NetworkUtil.error(error) {
                complete([String]())
                return
            }
            
            if let j = json as? Dictionary<String, AnyObject> {
                
                if let category = j["category"] as? [String] {
                    
                    if contains(category, "福利") {
                        
                        if let results = j["results"] as? Dictionary<String, AnyObject> {
                            
                            if let fulis = results["福利"] as? [Dictionary<String, AnyObject>] {
                                
                                var ret = [String]()
                                
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
            // No Beauty today, get a random beauty
            NetworkUtil.getRandomBeauty(1, complete: complete)
        }
    }
    
    class func getRandomBeauty(count: Int, complete: [String] -> Void) {
        
        let url = "\(API_RANDOM_URL)\(count)"
#if DEBUG
        println("Random URL --> \(url)")
#endif
        Alamofire.request(.GET, url).responseJSON {
            _, _, json, error in
            
            if NetworkUtil.error(error) {
                complete([String]())
                return
            }
            
            complete(NetworkUtil.parseBeautyList(json))
        }
    }
    
    class func parseBeautyList(json: AnyObject?) -> [String] {
        var ret = [String]()
        if let j = json as? Dictionary<String, AnyObject> {
            if let results = j["results"] as? [Dictionary<String, AnyObject>] {
                for b in results {
                    ret.append(b["url"] as! String)
                }
            }
        }
        return ret
    }
    
    class func error(error: NSError?) -> Bool {
        if error != nil {
            println("ERROR: \(error?.localizedDescription)")
            return true
        }
        return false
    }
}