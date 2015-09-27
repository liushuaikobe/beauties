//
//  HistoryViewController.swift
//  beauties
//
//  Created by Shuai Liu on 15/7/1.
//  Copyright (c) 2015年 Shuai Liu. All rights reserved.
//

import Foundation
import UIKit

class HistoryViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate {
    
    // ---------------- Views
    var beautyCollectionView: UICollectionView!
    var refreshControl: UIRefreshControl!
    // ---------------- Data
    var beauties: [BeautyImageEntity]
    let sharedMargin = 10
    var page = 1
    var isLoadingNow = false
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        beauties = []
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder aDecoder: NSCoder) {
        beauties = []
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.view.backgroundColor = ThemeColor
        self.edgesForExtendedLayout = .Bottom
        self.automaticallyAdjustsScrollViewInsets = true
        
        let statusBarHeight: CGFloat = 20
        
        let collectionViewLayout = UICollectionViewFlowLayout()
        collectionViewLayout.itemSize = CGSizeMake((CGRectGetWidth(self.view.bounds) - 10 * 3) / 2, 200)
        collectionViewLayout.minimumLineSpacing = 10
        collectionViewLayout.minimumInteritemSpacing = 10
        collectionViewLayout.sectionInset = UIEdgeInsetsMake(0, 10, 0, 10)
        
        var frame = self.view.bounds
        frame.origin.y += statusBarHeight
        self.beautyCollectionView = UICollectionView(frame: frame, collectionViewLayout: collectionViewLayout)
        self.beautyCollectionView.alwaysBounceVertical = true
        self.beautyCollectionView.backgroundColor = UIColor.clearColor()
        self.beautyCollectionView.collectionViewLayout = collectionViewLayout
        self.beautyCollectionView.delegate = self
        self.beautyCollectionView.dataSource = self
        self.beautyCollectionView.registerClass(BeautyCollectionViewCell.self, forCellWithReuseIdentifier: "BeautyCollectionViewCell")
        self.beautyCollectionView.registerClass(BeautyCollectionViewFooter.self, forSupplementaryViewOfKind:UICollectionElementKindSectionFooter, withReuseIdentifier: "BeautyCollectionViewFoooter")
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
    
    func fetchNextPage(page: Int) {
        if (self.page > BeautyDateUtil.MAX_PAGE) {
            return
        }
        if (self.isLoadingNow) {
            return
        }
        
        self.isLoadingNow = true
        print("---------- Starting Page \(page) ----------")
        
        NetworkUtil.getBeauties(page) {
            [weak self] result, error in
            print("---------- Finished Page \(page) ----------")
            
            if let sself = self {
                
                sself.isLoadingNow = false
                sself.refreshControl.endRefreshing()
                
                if error == nil {
                    sself.page += 1
                    sself.beauties += result.map(sself.buildEntityWithURLString)
                    sself.setBGI()
                    sself.beautyCollectionView.reloadData()
                }
            }
        }
    }
    
    // set Blur Background Image
    func setBGI() {
        if self.beauties.count == 0 {
            return
        }
        let beautyEntity = self.beauties[0]
        
        let bgi = UIImageView(frame: self.view.bounds)
        bgi.contentMode = .ScaleToFill
        self.view.addSubview(bgi)
        self.view.sendSubviewToBack(bgi)
        
        bgi.kf_setImageWithURL(NSURL(string: beautyEntity.imageUrl!)!, placeholderImage: nil, optionsInfo: nil) {
            image, error, cacheType, imageURL in
            bgi.applyBlurEffect()
        }
    }
    
    func buildEntityWithURLString(url: String) -> BeautyImageEntity {
        let b = BeautyImageEntity()
        b.imageUrl = url
        return b
    }
    
    // MARK: UIScrollViewDelegate
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if (scrollView.contentOffset.y + CGRectGetHeight(scrollView.bounds) > scrollView.contentSize.height) {
            self.fetchNextPage(self.page)
        }
    }
    
    // MARK: UICollectionViewDataSource
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return beauties.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("BeautyCollectionViewCell", forIndexPath: indexPath) as! BeautyCollectionViewCell
        if (indexPath.row < beauties.count) {
            let entity = beauties[indexPath.row]
            cell.bindData(entity)
        }
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let footer: BeautyCollectionViewFooter = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "BeautyCollectionViewFoooter", forIndexPath: indexPath) as! BeautyCollectionViewFooter
        if (kind == UICollectionElementKindSectionFooter) {
            footer.startAnimating()
        }
        return footer
    }
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if (indexPath.row < self.beauties.count) {
            let entity = self.beauties[indexPath.row]
            let todayViewController = TodayViewController()
            todayViewController.todayBeauty = entity
            todayViewController.canBeClosed = true
            self.presentViewController(todayViewController, animated: true, completion: nil)
        }
    }
}