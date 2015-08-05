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
    var beautyCollectionView: UICollectionView!
    var refreshControl: UIRefreshControl!
    var collectionViewLayout :CHTCollectionViewWaterfallLayout!
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
        self.view.backgroundColor = UIColor(red: CGFloat(163 / 255.0), green: CGFloat(191 / 255.0), blue: CGFloat(168 / 255.0), alpha: 1)
        self.automaticallyAdjustsScrollViewInsets = true
        
        let statusBarHeight: CGFloat = 20
        
        collectionViewLayout = CHTCollectionViewWaterfallLayout()
        collectionViewLayout.columnCount = 2
        collectionViewLayout.minimumColumnSpacing = CGFloat(sharedMargin)
        collectionViewLayout.minimumInteritemSpacing = CGFloat(sharedMargin)
        collectionViewLayout.sectionInset = UIEdgeInsets(top: 10, left: CGFloat(sharedMargin), bottom: CGRectGetHeight(self.tabBarController!.tabBar.frame) + statusBarHeight + 10 + 10, right: CGFloat(sharedMargin))
        collectionViewLayout.footerHeight = 50
        
        var frame = self.view.bounds
        frame.origin.y += statusBarHeight
        self.beautyCollectionView = UICollectionView(frame: frame, collectionViewLayout: collectionViewLayout)
        self.beautyCollectionView.alwaysBounceVertical = true
        self.beautyCollectionView.backgroundColor = UIColor.clearColor()
        self.beautyCollectionView.collectionViewLayout = collectionViewLayout
        self.beautyCollectionView.delegate = self
        self.beautyCollectionView.dataSource = self
        self.beautyCollectionView.registerClass(BeautyCollectionViewCell.self, forCellWithReuseIdentifier: "BeautyCollectionViewCell")
        self.beautyCollectionView.registerClass(BeautyCollectionViewFooter.self, forSupplementaryViewOfKind:collectionViewLayout.CHTCollectionElementKindSectionFooter, withReuseIdentifier: "BeautyCollectionViewFoooter")
        self.view.addSubview(self.beautyCollectionView!)
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.addTarget(self, action: Selector("refreshData"), forControlEvents: .ValueChanged)
        self.beautyCollectionView.addSubview(self.refreshControl)
        
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
        if (self.page > BeautyDateUtil.MAX_PAGE) {
            collectionViewLayout.footerHeight = 0
            return
        }
        if (self.isLoadingNow) {
            return
        }
        self.isLoadingNow = true
        println("---------- Starting Page \(page) ----------")
        let historyDates = BeautyDateUtil.generateHistoryDateString(page)
        var queue: dispatch_queue_t = dispatch_queue_create("Beauty", DISPATCH_QUEUE_CONCURRENT)
        historyDates.map({return (queue, $0)}).map(fetchData)
        
        dispatch_barrier_async(queue) {
            println("---------- Finished Page \(page) ----------")
            // ----- increment page by 1
            self.page += 1
            // ----- set background blur image
            if count(self.beauties) > 0 {
            
                var beautyEntity = self.beauties[0]
                
                var bgi = UIImageView(frame: self.view.bounds)
                bgi.contentMode = .ScaleToFill
                self.view.addSubview(bgi)
                self.view.sendSubviewToBack(bgi)
                
                bgi.kf_setImageWithURL(NSURL(string: beautyEntity.imageUrl!)!, placeholderImage: nil, optionsInfo: nil, completionHandler: { (image, error, cacheType, imageURL) -> () in
                    bgi.applyBlurEffect()
                })
            }
            
            // ----- reload data
            self.refreshControl.endRefreshing()
            self.beautyCollectionView.reloadData()
            
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
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let footer: BeautyCollectionViewFooter = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "BeautyCollectionViewFoooter", forIndexPath: indexPath) as! BeautyCollectionViewFooter
        if (kind == collectionViewLayout.CHTCollectionElementKindSectionFooter) {
            footer.startAnimating()
        }
        return footer
    }
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if (indexPath.row < count(self.beauties)) {
            var entity = self.beauties[indexPath.row]
            var todayViewController = TodayViewController()
            todayViewController.todayBeauty = entity
            todayViewController.canBeClosed = true
            self.presentViewController(todayViewController, animated: true, completion: nil)
        }
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