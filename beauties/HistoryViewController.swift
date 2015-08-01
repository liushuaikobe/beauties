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

class HistoryViewController: UIViewController, CHTCollectionViewDelegateWaterfallLayout, UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate {
    
    // ---------------- Views
    var beautyCollectionView: UICollectionView?
    var refreshControl: UIRefreshControl?
    // ---------------- Data
    var beauties: [BeautyImageEntity]
    let sharedMargin = 10
    var page = 1
    var isLoadingNow = false
    
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
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl!.addTarget(self, action: Selector("refreshData"), forControlEvents: .ValueChanged)
        self.beautyCollectionView!.addSubview(self.refreshControl!)
        
        // start loading data
        self.refreshData()
    }
    
    // MARK: fetch DATA
    
    func refreshData() {
        page = 1
        self.beauties.removeAll(keepCapacity: false)
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
        if (self.isLoadingNow || self.page > BeautyDateUtil.MAX_PAGE) {
            return
        }
        self.isLoadingNow = true
        println("fetch data for page --> \(page)")
        let historyDates = BeautyDateUtil.generateHistoryDateString(page)
        var queue: dispatch_queue_t = dispatch_queue_create("Beauty", DISPATCH_QUEUE_CONCURRENT)
        historyDates.map({return (queue, $0)}).map(fetchData)
        
        dispatch_barrier_async(queue) {
            // ----- increment page by 1
            self.page += 1
            // ----- set background blur image
            var beautyEntity = self.beauties[Int(count(self.beauties) / 2)]
            
            var bgi = UIImageView(frame: self.view.bounds)
            bgi.contentMode = .ScaleToFill
            self.view.addSubview(bgi)
            self.view.sendSubviewToBack(bgi)
            
            bgi.kf_setImageWithURL(NSURL(string: beautyEntity.imageUrl!)!, placeholderImage: nil, optionsInfo: nil, completionHandler: { (image, error, cacheType, imageURL) -> () in
                bgi.applyBlurEffect()
            })
            
            // ----- reload data
            self.refreshControl!.endRefreshing()
            self.beautyCollectionView!.reloadData()
            
            self.isLoadingNow = false
        }
    }
    
    // MARK: UIScrollViewDelegate
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if (scrollView.contentOffset.y + CGRectGetHeight(scrollView.bounds) > scrollView.contentSize.height) {
            self.fetchNextPage(self.page)
        }
    }
    
    // MARK: UICollectionViewDataSource
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return count(beauties)
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell = collectionView.dequeueReusableCellWithReuseIdentifier("BeautyCollectionViewCell", forIndexPath: indexPath) as! BeautyCollectionViewCell
        if (indexPath.row < count(beauties)) {
            var entity = beauties[indexPath.row]
            cell.bindData(entity)
        }
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        println("\(indexPath.row)")
    }
    
    // MARK: CHTCollectionViewDelegateWaterfallLayout
    
    func collectionView (collectionView: UICollectionView,layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        var entity = beauties[indexPath.row]
        let width: Float = (Float(collectionView.bounds.size.width) - Float(sharedMargin) * 3) / 2
        
        var height:Float = 200.0
        if entity.imageHeight != nil && entity.imageWidth != nil {
            height = (Float(entity.imageHeight!) * width) / Float(entity.imageWidth!)
        }
            
        return CGSize(width: CGFloat(width), height: CGFloat(height))
    }
}