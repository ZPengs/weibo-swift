//
//  ComposeViewController.swift
//  DS11WB
//
//  Created by xiaomage on 16/4/9.
//  Copyright © 2016年 小码哥. All rights reserved.
//

import UIKit
import SVProgressHUD

class ComposeViewController: UIViewController {
    // MARK:- 控件属性
    @IBOutlet weak var textView: ComposeTextView!
    @IBOutlet weak var picPickerView: PicPickerCollectionView!
    
    // MARK:- 懒加载属性
    private lazy var titleView : ComposeTitleView = ComposeTitleView()
    private lazy var images : [UIImage] = [UIImage]()
    private lazy var emoticonVc : EmoticonController = EmoticonController {[weak self] (emoticon) -> () in
        self?.textView.insertEmoticon(emoticon)
        self?.textViewDidChange(self!.textView)
    }
    
    // MARK:- 约束的属性
    @IBOutlet weak var toolBarBottomCons: NSLayoutConstraint!
    @IBOutlet weak var picPicerViewHCons: NSLayoutConstraint!
    
    // MARK:- 系统回调函数
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 设置导航栏
        setupNavigationBar()
        
        // 监听通知
        setupNotifications()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        textView.becomeFirstResponder()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}


// MARK:- 设置UI界面
extension ComposeViewController {
    
    private func setupNavigationBar() {
        // 1.设置左右的item
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "关闭", style: .Plain, target: self, action: "closeItemClick")
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "发送", style: .Plain, target: self, action: "sendItemClick")
        navigationItem.rightBarButtonItem?.enabled = false
        
        // 2.设置标题
        titleView.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        navigationItem.titleView = titleView
    }
    
    private func setupNotifications() {
        // 监听键盘的弹出
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillChangeFrame:", name: UIKeyboardWillChangeFrameNotification, object: nil)
        
        // 监听添加照片的按钮的点击
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "addPhotoClick", name: PicPickerAddPhotoNote, object: nil)
        
        // 监听删除照片的按钮的点击
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "removePhotoClick:", name: PicPickerRemovePhotoNote, object: nil)
    }
}


// MARK:- 事件监听函数
extension ComposeViewController {
    @objc private func closeItemClick() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @objc private func sendItemClick() {
        // 0.键盘退出
        textView.resignFirstResponder()
        
        // 1.获取发送微博的微博正文
        let statusText = textView.getEmoticonString()
        
        // 2.定义回调的闭包
        let finishedCallback = { (isSuccess : Bool) -> () in
            if !isSuccess {
                SVProgressHUD.showErrorWithStatus("发送微博失败")
                return
            }
            SVProgressHUD.showSuccessWithStatus("发送微博成功")
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        
        // 3.获取用户选中的图片
        if let image = images.first {
            NetworkTools.shareInstance.sendStatus(statusText, image: image, isSuccess: finishedCallback)
        } else {
            NetworkTools.shareInstance.sendStatus(statusText, isSuccess: finishedCallback)
        }
    }
    
    @objc private func keyboardWillChangeFrame(note : NSNotification) {
        // 1.获取动画执行的时间
        let duration = note.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! NSTimeInterval
        
        // 2.获取键盘最终Y值
        let endFrame = (note.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        let y = endFrame.origin.y
        
        // 3.计算工具栏距离底部的间距
        let margin = UIScreen.mainScreen().bounds.height - y
        
        // 4.执行动画
        toolBarBottomCons.constant = margin
        UIView.animateWithDuration(duration) { () -> Void in
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func picPickerBtnClick() {
        // 退出键盘
        textView.resignFirstResponder()
        
        // 执行动画
        picPicerViewHCons.constant = UIScreen.mainScreen().bounds.height * 0.65
        UIView.animateWithDuration(0.5) { () -> Void in
            self.view.layoutIfNeeded()
        }
    }
    
    
    @IBAction func emoticonBtnClick() {
        // 1.退出键盘
        textView.resignFirstResponder()
        
        // 2.切换键盘
        textView.inputView = textView.inputView != nil ? nil : emoticonVc.view
        
        // 3.弹出键盘
        textView.becomeFirstResponder()
    }
}


// MARK:- 添加照片和删除照片的事件
extension ComposeViewController {
    @objc private func addPhotoClick() {
        // 1.判断数据源是否可用
        if !UIImagePickerController.isSourceTypeAvailable(.PhotoLibrary) {
            return
        }
        
        // 2.创建照片选择控制器
        let ipc = UIImagePickerController()
        
        // 3.设置照片源
        ipc.sourceType = .PhotoLibrary
        
        // 4.设置代理
        ipc.delegate = self
        
        // 弹出选择照片的控制器
        presentViewController(ipc, animated: true, completion: nil)
    }
    
    @objc private func removePhotoClick(note : NSNotification) {
        // 1.获取image对象
        guard let image = note.object as? UIImage else {
            return
        }
        
        // 2.获取image对象所在下标值
        guard let index = images.indexOf(image) else {
            return
        }
        
        // 3.将图片从数组删除
        images.removeAtIndex(index)
        
        // 4.重写赋值collectionView新的数组
        picPickerView.images = images
    }
}

// MARK:- UIImagePickerController的代理方法
extension ComposeViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        // 1.获取选中的照片
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        // 2.将选中的照片添加到数组中
        images.append(image)
        
        // 3.将数组赋值给collectionView,让collectionView自己去展示数据
        picPickerView.images = images
        
        // 4.退出选中照片控制器
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
}


// MARK:- UITextView的代理方法
extension ComposeViewController : UITextViewDelegate {
    func textViewDidChange(textView: UITextView) {
        self.textView.placeHolderLabel.hidden = textView.hasText()
        navigationItem.rightBarButtonItem?.enabled = textView.hasText()
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        textView.resignFirstResponder()
    }
}











