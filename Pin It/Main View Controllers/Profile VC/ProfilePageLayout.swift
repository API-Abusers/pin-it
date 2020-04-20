//
//  ProfilePageLayout.swift
//  Pin It
//
//  Created by Joseph Jin on 4/19/20.
//  Copyright © 2020 AnimatorJoe. All rights reserved.
//

import UIKit
import LayoutKit
import ImageSlideshow
import PromiseKit
import Firebase
import NotificationBannerSwift
import Kingfisher

public class ProfilePageLayout: InsetLayout<UIView> {

    init(_ rootvc: UIViewController) {
        let user = Auth.auth().currentUser!
        
        let pfpLayout = SizeLayout<UIImageView>(
            width: 50,
            height: 50,
            alignment: .centerTrailing) { imageView in
            let processor = RoundCornerImageProcessor(cornerRadius: imageView.frame.width)
            imageView.kf.setImage(with: user.photoURL!,
                                  options: [.processor(processor)])
        }
        
        let usernameLayout = LabelLayout(text: user.displayName!,
                                         font: .boldSystemFont(ofSize: 40),
                                         alignment: .centerLeading)
        
        let userBarLayout = InsetLayout<UIView>(insets: EdgeInsets(top: 0, left: 0, bottom: 0, right: 0),
                                                alignment: .center,
                                                sublayout: StackLayout(axis: .horizontal,
                                                                       spacing: 10,
                                                                       sublayouts: [pfpLayout, usernameLayout]))
        
        let exitButtonLayout = SizeLayout<UIButton>(width: 360,
                                                    height: 40,
                                                    alignment: .bottomCenter,
                                                    flexibility: .inflexible) { button in
            button.layer.cornerRadius = 4
            button.backgroundColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
            button.titleLabel?.font = .boldSystemFont(ofSize: 16)
            button.setTitle("Log Out", for: .normal)
            
            button.addTapGestureRecognizer {
                rootvc.dismiss(animated: true) {
                    let appDelegate: AppDelegate? = UIApplication.shared.delegate as? AppDelegate
                    appDelegate!.signOutCurrentUser()
                }
            }
        }
            
        super.init(
            insets: UIEdgeInsets(top: 25, left: 25, bottom: 0, right: 25),
            sublayout: StackLayout(
                axis: .vertical,
                spacing: 25,
                sublayouts: [
                    userBarLayout,
                    exitButtonLayout]
            )
        )
    
    }
}

