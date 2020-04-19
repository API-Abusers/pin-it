//
//  ProfileViewController.swift
//  Pin It
//
//  Created by Joseph Jin on 1/14/20.
//  Copyright © 2020 AnimatorJoe. All rights reserved.
//

import UIKit
import LBTATools
import Alamofire
import Firebase
import GoogleSignIn

class ProfileViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        view.backgroundColor = .white
        
        let pfpage = ProfilePageLayout(self)
        let arrangment = pfpage.arrangement(width: self.view.frame.width)
        arrangment.makeViews(in: self.view)
    }
    
}
