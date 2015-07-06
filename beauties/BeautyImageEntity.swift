//
//  BeautyImageEntity.swift
//  beauties
//
//  Created by Shuai Liu on 15/6/30.
//  Copyright (c) 2015年 Shuai Liu. All rights reserved.
//

import Foundation

class BeautyImageEntity: NSObject, NSCoding {
    var imageUrl: String?
    var imageHeight: Int?
    var imageWidth: Int?
    
    override var description: String {
        return "imageUrl: \(self.imageUrl), imageHeight: \(self.imageHeight), imageWidth: \(self.imageWidth)"
    }
    
    override init() {
        
    }
    
    required init(coder aDecoder: NSCoder) {
        imageUrl = aDecoder.decodeObjectForKey("imageUrl") as? String
        imageHeight = aDecoder.decodeObjectForKey("imageHeight") as? Int
        imageWidth = aDecoder.decodeObjectForKey("imageWidth") as? Int
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(imageUrl, forKey: "imageUrl")
        aCoder.encodeObject(imageHeight, forKey: "imageHeight")
        aCoder.encodeObject(imageWidth, forKey: "imageWidth")
    }
}