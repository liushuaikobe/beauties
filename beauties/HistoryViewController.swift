//
//  HistoryViewController.swift
//  beauties
//
//  Created by Shuai Liu on 15/7/1.
//  Copyright (c) 2015年 Shuai Liu. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

class HistoryViewController: UIViewController, CHTCollectionViewDelegateWaterfallLayout, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var beauties: [BeautyImageEntity]
    var beautyCollectionView: UICollectionView?
    let sharedMargin = 10
    
    var page = 1
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        beauties = []
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init(coder aDecoder: NSCoder) {
        beauties = []
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let statusBarHeight: CGFloat = 20
        
        var collectionViewLayout = CHTCollectionViewWaterfallLayout()
        collectionViewLayout.columnCount = 2
        collectionViewLayout.minimumColumnSpacing = CGFloat(sharedMargin)
        collectionViewLayout.minimumInteritemSpacing = CGFloat(sharedMargin)
        collectionViewLayout.sectionInset = UIEdgeInsets(top: 10, left: CGFloat(sharedMargin), bottom: CGRectGetHeight(self.tabBarController!.tabBar.frame) + statusBarHeight + 10 + 10, right: CGFloat(sharedMargin))
        
        var frame = self.view.bounds
        frame.origin.y += statusBarHeight
        self.beautyCollectionView = UICollectionView(frame: frame, collectionViewLayout: collectionViewLayout)
        self.beautyCollectionView!.backgroundColor = UIColor.clearColor()
        self.beautyCollectionView!.collectionViewLayout = collectionViewLayout
        self.beautyCollectionView!.delegate = self
        self.beautyCollectionView!.dataSource = self
        self.beautyCollectionView!.registerClass(BeautyCollectionViewCell.self, forCellWithReuseIdentifier: "BeautyCollectionViewCell")
        self.view.addSubview(self.beautyCollectionView!)
        
        // start loading data
        self.refreshData()
    }
    
    // MARK: fetch DATA
    
    func refreshData() {
        page = 1
        self.fetchNextPage(page)
    }
    
    func fetchData(args: (dispatch_queue_t, String)) {
        dispatch_async(args.0) {
            var beauty = NetworkUtil.getImageByDateSync(args.1)
            if beauty != nil {
                self.beauties.append(beauty!)
            }
        }
    }
    
    func fetchNextPage(page: Int) {
        let historyDates = BeautyDateUtil.generateHistoryDateString(format: BeautyDateUtil.API_FORMAT, historyCount: BeautyDateUtil.PAGE_SIZE)
        var queue: dispatch_queue_t = dispatch_queue_create("Beauty", DISPATCH_QUEUE_CONCURRENT)
        historyDates.map({return (queue, $0)}).map(fetchData)
        
        dispatch_barrier_async(queue) {
            // ----- set background blur image
            let diceRoll = Int(arc4random_uniform(UInt32(self.beauties.count)))
            var beautyEntity = self.beauties[0]
            
            var bgi = UIImageView(frame: self.view.bounds)
            bgi.contentMode = .ScaleToFill
            self.view.addSubview(bgi)
            self.view.sendSubviewToBack(bgi)
            
            bgi.kf_setImageWithURL(NSURL(string: beautyEntity.imageUrl!)!, placeholderImage: nil, optionsInfo: nil, completionHandler: { (image, error, cacheType, imageURL) -> () in
                bgi.applyBlurEffect()
            })
            
            // ----- reload data
            self.beautyCollectionView!.reloadData()
        }
    }
    
    // MARK: UICollectionViewDataSource
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return count(beauties)
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell = collectionView.dequeueReusableCellWithReuseIdentifier("BeautyCollectionViewCell", forIndexPath: indexPath) as! BeautyCollectionViewCell
        var entity = beauties[indexPath.row]
        cell.bindData(entity)
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    
    // MARK: CHTCollectionViewDelegateWaterfallLayout
    
    func collectionView (collectionView: UICollectionView,layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        var entity = beauties[indexPath.row]
        let width: Float = (Float(collectionView.bounds.size.width) - Float(sharedMargin) * 3) / 2
        let height = (Float(entity.imageHeight!) * width) / Float(entity.imageWidth!)
        return CGSize(width: CGFloat(width), height: CGFloat(height))
    }
}