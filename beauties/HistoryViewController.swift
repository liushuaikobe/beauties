//
//  HistoryViewController.swift
//  beauties
//
//  Created by Shuai Liu on 15/7/1.
//  Copyright (c) 2015年 Shuai Liu. All rights reserved.
//

import Foundation
import UIKit

class HistoryViewController: UIViewController, CHTCollectionViewDelegateWaterfallLayout, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var beauties: [BeautyImageEntity]
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        beauties = []
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init(coder aDecoder: NSCoder) {
        beauties = []
        super.init(coder: aDecoder)
    }
    
    @IBOutlet weak var beautyCollectionView: UICollectionView!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        var collectionViewLayout = CHTCollectionViewWaterfallLayout()
        collectionViewLayout.columnCount = 2
        collectionViewLayout.minimumColumnSpacing = 20
        collectionViewLayout.minimumInteritemSpacing = 20
        
        self.beautyCollectionView.collectionViewLayout = collectionViewLayout
        self.beautyCollectionView.delegate = self
        self.beautyCollectionView.dataSource = self
    }
    
    // MARK: UICollectionViewDataSource
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return count(beauties)
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell = collectionView.dequeueReusableCellWithReuseIdentifier("", forIndexPath: indexPath) as! BeautyCollectionViewCell
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    
    // MARK: CHTCollectionViewDelegateWaterfallLayout
    
    func collectionView (collectionView: UICollectionView,layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
            return CGSizeZero
    }
}