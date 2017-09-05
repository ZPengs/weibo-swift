//
//  PhotoBrowserViewCell.swift
//  DS11WB
//
//  Created by xiaomage on 16/4/13.
//  Copyright © 2016年 小码哥. All rights reserved.
//

import UIKit
import SDWebImage


protocol PhotoBrowserViewCellDelegate : NSObjectProtocol {
    func imageViewClick()
}

class PhotoBrowserViewCell: UICollectionViewCell {
    // MARK:- 定义属性
    var picURL : NSURL? {
        didSet {
            setupContent(picURL)
        }
    }
    
    var delegate : PhotoBrowserViewCellDelegate?
    
    // MARK:- 懒加载属性
    private lazy var scrollView : UIScrollView = UIScrollView()
    private lazy var progressView : ProgressView = ProgressView()
    lazy var imageView : UIImageView = UIImageView()
    
    // MARK:- 构造函数
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


// MARK:- 设置UI界面内容
extension PhotoBrowserViewCell {
    private func setupUI() {
        // 1.添加子控件
        contentView.addSubview(scrollView)
        contentView.addSubview(progressView)
        scrollView.addSubview(imageView)
        
        // 2.设置子控件frame
        scrollView.frame = contentView.bounds
        scrollView.frame.size.width -= 20
        progressView.bounds = CGRect(x: 0, y: 0, width: 50, height: 50)
        progressView.center = CGPoint(x: UIScreen.mainScreen().bounds.width * 0.5, y: UIScreen.mainScreen().bounds.height * 0.5)
        
        // 3.设置控件的属性
        progressView.hidden = true
        progressView.backgroundColor = UIColor.clearColor()
        
        // 4.监听imageView的点击
        let tapGes = UITapGestureRecognizer(target: self, action: "imageViewClick")
        imageView.addGestureRecognizer(tapGes)
        imageView.userInteractionEnabled = true
    }
}


// MARK:- 事件监听
extension PhotoBrowserViewCell {
    @objc private func imageViewClick() {
        delegate?.imageViewClick()
    }
}

// MARK:- 设置cell的内容
extension PhotoBrowserViewCell {
    private func setupContent(picURL : NSURL?) {
        // 1.nil值校验
        guard let picURL = picURL else {
            return
        }
        
        // 2.取出image对象
        let image = SDWebImageManager.sharedManager().imageCache.imageFromDiskCacheForKey(picURL.absoluteString)
        
        // 3.计算imageView的frame
        let width = UIScreen.mainScreen().bounds.width
        let height = width / image.size.width * image.size.height
        var y : CGFloat = 0
        if height > UIScreen.mainScreen().bounds.height {
            y = 0
        } else {
            y = (UIScreen.mainScreen().bounds.height - height) * 0.5
        }
        imageView.frame = CGRect(x: 0, y: y, width: width, height: height)
        
        // 4.设置imagView的图片
        progressView.hidden = false
        imageView.sd_setImageWithURL(getBigURL(picURL), placeholderImage: image, options: [], progress: { (current, total) -> Void in
            self.progressView.progress = CGFloat(current) / CGFloat(total)
            }) { (_, _, _, _) -> Void in
                self.progressView.hidden = true
        }
        
        // 5.设置scrollView的contentSize
        scrollView.contentSize = CGSize(width: 0, height: height)
    }
    
    private func getBigURL(smallURL : NSURL) -> NSURL {
        let smallURLString = smallURL.absoluteString
        let bigURLString = smallURLString.stringByReplacingOccurrencesOfString("thumbnail", withString: "bmiddle")
        
        return NSURL(string: bigURLString)!
    }
}








