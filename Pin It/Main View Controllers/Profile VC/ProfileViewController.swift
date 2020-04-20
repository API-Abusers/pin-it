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
import LayoutKit

class ProfileViewController: UIViewController {
    
    var isRendered = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        view.backgroundColor = .white
    }
    
    func renderView(onCompletion execute: ((LayoutArrangement) -> ())?) {
        if isRendered { return }
        let pfpage = ProfilePageLayout(self)
        let arrangment = pfpage.arrangement(width: self.view.frame.width)
        arrangment.makeViews(in: self.view)
        if let e = execute { e(arrangment) }
        isRendered = true
    }
    
}
