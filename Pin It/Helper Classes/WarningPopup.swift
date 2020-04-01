//
//  WarningPopup.swift
//  Pin It
//
//  Created by Joseph Jin on 3/31/20.
//  Copyright © 2020 AnimatorJoe. All rights reserved.
//

import Foundation
import UIKit

class WarningPopup {
    // MARK: Issue Warning
    static func issueWarningOnIncompletePost(vc: UIViewController) {
        WarningPopup.issueWarning(title: "Incomplete Post", description: "Please finish your post", vc: vc)
    }
    
    static func issueWarningOnInternetConnection(vc: UIViewController) {
        WarningPopup.issueWarning(title: "No Internet Connection", description: "Please enable your internet connection", vc: vc)
    }
    
    static func issueWarning(title: String, description: String, vc: UIViewController) {
        let alert = UIAlertController(title: title, message: description, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
        vc.present(alert, animated: true, completion: nil)
    }
}
