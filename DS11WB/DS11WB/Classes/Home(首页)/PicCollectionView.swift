//
//  PicCollectionView.swift
//  DS11WB
//
//  Created by xiaomage on 16/4/9.
//  Copyright © 2016年 小码哥. All rights reserved.
//

import UIKit
import SDWebImage

class PicCollectionView: UICollectionView {
    
    // MARK:- 定义属性
    var picURLs : [NSURL] = [NSURL]() {
        didSet {
            self.reloadData()
        }
    }
    
    // MARK:- 系统回调函数
    override func awakeFromNib() {
        super.awakeFromNib()
        
        dataSource = self
        delegate = self
    }
}


// MARK:- collectionView的数据源方法
extension PicCollectionView : UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return picURLs.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        // 1.获取cell
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PicCell", forIndexPath: indexPath) as! PicCollectionViewCell
        
        // 2.给cell设置数据
        cell.picURL = picURLs[indexPath.item]
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        // 1.获取通知需要传递的参数
        let userInfo = [ShowPhotoBrowserIndexKey : indexPath, ShowPhotoBrowserUrlsKey : picURLs]
        
        // 2.发出通知
        NSNotificationCenter.defaultCenter().postNotificationName(ShowPhotoBrowserNote, object: self, userInfo: userInfo)
    }
}

extension PicCollectionView : AnimatorPresentedDelegate {
    func startRect(indexPath: NSIndexPath) -> CGRect {
        // 1.获取cell
        let cell = self.cellForItemAtIndexPath(indexPath)!
        
        // 2.获取cell的frame
        let startFrame = self.convertRect(cell.frame, toCoordinateSpace: UIApplication.sharedApplication().keyWindow!)
        
        return startFrame
    }
    
    func endRect(indexPath: NSIndexPath) -> CGRect {
        // 1.获取该位置的image对象
        let picURL = picURLs[indexPath.item]
        let image = SDWebImageManager.sharedManager().imageCache.imageFromDiskCacheForKey(picURL.absoluteString)
        
        // 2.计算结束后的frame
        let w = UIScreen.mainScreen().bounds.width
        let h = w / image.size.width * image.size.height
        var y : CGFloat = 0
        if h > UIScreen.mainScreen().bounds.height {
            y = 0
        } else {
            y = (UIScreen.mainScreen().bounds.height - h) * 0.5
        }
        
        return CGRect(x: 0, y: y, width: w, height: h)
    }
    
    func imageView(indexPath: NSIndexPath) -> UIImageView {
        // 1.创建UIImageView对象
        let imageView = UIImageView()
        
        // 2.获取该位置的image对象
        let picURL = picURLs[indexPath.item]
        let image = SDWebImageManager.sharedManager().imageCache.imageFromDiskCacheForKey(picURL.absoluteString)
        
        // 3.设置imageView的属性
        imageView.image = image
        imageView.contentMode = .ScaleAspectFill
        imageView.clipsToBounds = true
        
        return imageView
    }
}



class PicCollectionViewCell : UICollectionViewCell {
    // MARK:- 定义模型属性
    var picURL : NSURL? {
        didSet {
            guard let picURL = picURL else {
                return
            }
            
            iconVIew.sd_setImageWithURL(picURL, placeholderImage: UIImage(named: "empty_picture"))
        }
    }
    
    // MARK:- 控件的属性
    @IBOutlet weak var iconVIew: UIImageView!
}






