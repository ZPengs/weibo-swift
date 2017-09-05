//
//  PhotoBrowserAnimator.swift
//  DS11WB
//
//  Created by xiaomage on 16/4/13.
//  Copyright © 2016年 小码哥. All rights reserved.
//

import UIKit


// 面向协议开发
protocol AnimatorPresentedDelegate : NSObjectProtocol {
    func startRect(indexPath : NSIndexPath) -> CGRect
    func endRect(indexPath : NSIndexPath) -> CGRect
    func imageView(indexPath : NSIndexPath) -> UIImageView
}

protocol AnimatorDismissDelegate : NSObjectProtocol {
    func indexPathForDimissView() -> NSIndexPath
    func imageViewForDimissView() -> UIImageView
}

class PhotoBrowserAnimator: NSObject {
    var isPresented : Bool = false
    
    var presentedDelegate : AnimatorPresentedDelegate?
    var dismissDelegate : AnimatorDismissDelegate?
    var indexPath : NSIndexPath?
}

extension PhotoBrowserAnimator : UIViewControllerTransitioningDelegate {
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isPresented = true
        return self
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isPresented = false
        return self
    }
}

extension PhotoBrowserAnimator : UIViewControllerAnimatedTransitioning {
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.5
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        isPresented ? animationForPresentedView(transitionContext) : animationForDismissView(transitionContext)
    }
    
    func animationForPresentedView(transitionContext: UIViewControllerContextTransitioning) {
        // 0.nil值校验
        guard let presentedDelegate = presentedDelegate, indexPath = indexPath else {
            return
        }
        
        // 1.取出弹出的View
        let presentedView = transitionContext.viewForKey(UITransitionContextToViewKey)!
        
        // 2.将prensentedView添加到containerView中
        transitionContext.containerView()?.addSubview(presentedView)
        
        // 3.获取执行动画的imageView
        let startRect = presentedDelegate.startRect(indexPath)
        let imageView = presentedDelegate.imageView(indexPath)
        transitionContext.containerView()?.addSubview(imageView)
        imageView.frame = startRect
        
        // 4.执行动画
        presentedView.alpha = 0.0
        transitionContext.containerView()?.backgroundColor = UIColor.blackColor()
        UIView.animateWithDuration(transitionDuration(transitionContext), animations: { () -> Void in
            imageView.frame = presentedDelegate.endRect(indexPath)
            }) { (_) -> Void in
                imageView.removeFromSuperview()
                presentedView.alpha = 1.0
                transitionContext.containerView()?.backgroundColor = UIColor.clearColor()
                transitionContext.completeTransition(true)
        }
    }
    
    func animationForDismissView(transitionContext: UIViewControllerContextTransitioning) {
        // nil值校验
        guard let dismissDelegate = dismissDelegate, presentedDelegate = presentedDelegate else {
            return
        }
        
        // 1.取出消失的View
        let dismissView = transitionContext.viewForKey(UITransitionContextFromViewKey)
        dismissView?.removeFromSuperview()
        
        // 2.获取执行动画的ImageView
        let imageView = dismissDelegate.imageViewForDimissView()
        transitionContext.containerView()?.addSubview(imageView)
        let indexPath = dismissDelegate.indexPathForDimissView()
        
        // 3.执行动画
        UIView.animateWithDuration(transitionDuration(transitionContext), animations: { () -> Void in
            imageView.frame = presentedDelegate.startRect(indexPath)
            }) { (_) -> Void in
                transitionContext.completeTransition(true)
        }
    }
}