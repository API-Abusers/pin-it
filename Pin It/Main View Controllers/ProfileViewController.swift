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

class ProfileViewController: LBTAFormController {

    var titleLabel = UILabel()
    var authorLabel = UILabel()
    var descLabel = UILabel()
    
    let logoutButton = UIButton(title: "Log Out", titleColor: .white, font: .boldSystemFont(ofSize: 16), backgroundColor: #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1), target: self, action: #selector(logOut))
    
    var lineView = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 1))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .dark
        view.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        
        let user = Auth.auth().currentUser
        
        // Setting up view layout
        formContainerStackView.axis = .vertical
        formContainerStackView.spacing = 25
        formContainerStackView.layoutMargins = .init(top: 25, left: 25, bottom: 0, right: 25)
        
        // Title label
        titleLabel = UILabel(text: user?.displayName!, font: UIFont.boldSystemFont(ofSize: 40), textColor: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), textAlignment: .natural, numberOfLines: 0)
        titleLabel.resizeAndDisplayText(text: user!.displayName!)
        formContainerStackView.addArrangedSubview(titleLabel)
        
        // Author label
//        authorLabel = UILabel(text: entry?.username, font: UIFont.italicSystemFont(ofSize: 15), textColor: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), textAlignment: .natural, numberOfLines: 0)
//        authorLabel.resizeAndDisplayText(text: entry!.username)
//        formContainerStackView.addArrangedSubview(authorLabel)
        
        // Description label
//        descLabel = UILabel(text: entry?.description, font: UIFont.systemFont(ofSize: 20), textColor: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), textAlignment: .natural, numberOfLines: 0)
//        descLabel.resizeAndDisplayText(text: entry!.description)
//        formContainerStackView.addArrangedSubview(descLabel)
        
        // Buttons
        formContainerStackView.addArrangedSubview(logoutButton)
        
    }
    
    // MARK: Log Out
    @objc fileprivate func logOut() {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            self.dismiss(animated: true)
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
}
