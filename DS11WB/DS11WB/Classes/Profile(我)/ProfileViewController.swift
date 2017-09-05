//
//  ProfileViewController.swift
//  DS11WB
//
//  Created by xiaomage on 16/4/1.
//  Copyright © 2016年 小码哥. All rights reserved.
//

import UIKit

class ProfileViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        visitorView.setupVisitorViewInfo("visitordiscover_image_profile", title: "登录后，你的微博、相册、个人资料会显示在这里，展示给别人")
    }
    
}
