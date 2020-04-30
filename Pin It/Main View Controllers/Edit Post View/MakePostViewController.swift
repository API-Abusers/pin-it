//
//  MakePostViewController.swift
//  Pin It
//
//  Created by Joseph Jin on 1/9/20.
//  Copyright © 2020 AnimatorJoe. All rights reserved.
//

import UIKit
import Alamofire
import Firebase
import GoogleSignIn
import PromiseKit
import AwaitKit
import Eureka
import MultiImageRow
import NVActivityIndicatorView
import NotificationBannerSwift
import SPFakeBar

class MakePostViewController: FormViewController, NVActivityIndicatorViewable {
    
    let navBar = SPFakeBarView(style: .stork)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        self.isModalInPresentation = true
        
        self.navBar.titleLabel.text = "Make a Post"
        self.navBar.leftButton.setTitle("Cancel", for: .normal)
        self.navBar.leftButton.addTapGestureRecognizer { self.exitView() }
        
        self.navBar.rightButton.setTitle("Post", for: .normal)
        self.navBar.rightButton.addTapGestureRecognizer { self.sendPost() }

        self.view.addSubview(self.navBar)
        
        createForm()
    }
    
    // MARK: Create Form
    func createForm() {
        form
            +++ Section(){ section in
                var header = HeaderFooterView(title: "")
                header?.height = { self.navBar.height + 10 }
                section.header = header
            }
            
            // Image selector
            <<< MultiImagePickerRow(fromController: .specific(self)) { row in
                row.descriptionTitle = "Select images"
                row.tag = "images"
                row.value = [.empty,.empty,.empty]
            }
            
            +++ Section()
            // Location selector
            <<< LocationRow(){
                $0.title = "Select Location"
                $0.value = MapViewController.userLoc
                $0.tag = "location"
                $0.validationOptions = .validatesOnChange //2
            }
            
            // Text inputs
            +++ Section()
            <<< TextRow() { row in
                row.placeholder = "Write a title..."
                row.tag = "title"
            }
            .cellSetup{ cell, row in
            }
            
            <<< TextAreaRow() { row in
                row.placeholder = "Write a description..."
                row.tag = "desc"
            }
            .cellSetup { cell, row in
                cell.height = { 150 }
            }
            
            // Button rows
//            +++ Section()
//            <<< ButtonRow { button in
//                button.title = "Post"
//            }
//            .cellSetup { cell, row in
//                cell.backgroundColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
//                cell.tintColor = .white
//            }
//            .onCellSelection { cell, row in
//                self.sendPost()
//            }
//
//            <<< ButtonRow { (row: ButtonRow) -> Void in
//                row.title = "Exit"
//            }
//            .cellSetup{ cell, row in
//                cell.backgroundColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
//                cell.tintColor = .white
//            }
//            .onCellSelection { cell, row in
//                self.exitView()
//            }
    }
    
    // MARK: Sending Post
    @objc func sendPost() {
        let user = Auth.auth().currentUser

        if !Connectivity.isConnectedToInternet {
            WarningPopup.issueWarningOnInternetConnection(vc: self)
            return
        }
        
        // unwrap user selections and check for completion
        guard let imageSlots = self.form.rowBy(tag: "images")!.baseValue as! [MultiImageTableCellSlot]? else {
            WarningPopup.issueWarning(title: "Incomplete Post", description: "Please add images to your post", vc: self)
            return
        }
    
        var imageSelection = [UIImage]()
        for i in imageSlots {
            switch i {
            case .image(let img):
                imageSelection.append(img)
            default:
                continue
            }
        }
        
        if imageSelection.isEmpty {
            WarningPopup.issueWarning(title: "Incomplete Post", description: "Please add images to your post", vc: self)
            return
        }
        
        guard let locField = self.form.rowBy(tag: "location")!.baseValue as! CLLocation? else {
            WarningPopup.issueWarning(title: "Incomplete Post", description: "Please add a location", vc: self)
            return
        }
        
        guard let titleField = self.form.rowBy(tag: "title")!.baseValue as! String? else {
            WarningPopup.issueWarning(title: "Incomplete Post", description: "Please add a title", vc: self)
            return
        }
        
        guard let descField = self.form.rowBy(tag: "desc")!.baseValue as! String? else {
            WarningPopup.issueWarning(title: "Incomplete Post", description: "Please add a description", vc: self)
            return
        }
        
        
        if(titleField.isEmpty || descField.isEmpty) {
            WarningPopup.issueWarningOnIncompletePost(vc: self)
            return
        }
    

        // make post request
        var data: [String: Any] = [
            "title" : titleField,
            "description" : descField,
            "userName": user?.displayName ?? "foo",
            "userLat": locField.coordinate.latitude,
            "userLong": locField.coordinate.longitude,
            "timestamp": Date(),
            "owner": Auth.auth().currentUser?.uid ?? "none",
            "action": "create"
        ]

        var hasher = Hasher()
        hasher.combine(titleField)
        hasher.combine(descField)
        hasher.combine(user?.displayName)
        hasher.combine(Date())
        let hash = hasher.finalize()
        
        data["id"] = String(describing: hash)
        
        self.dismiss(animated: true)
        
        let uploadIndicator = FloatingNotificationBanner(title: "Uploading Post", style: .info)
        uploadIndicator.show()
        
        firstly {
            EntriesManager.postEntry(data: data)
        }.then {_ in
            EntriesManager.attachImageFiles(files: imageSelection, addTo: data["id"] as! String)
        }.done { _ in
            uploadIndicator.dismiss()
            if AppConfigs.requiresAuditing {
                let uploadNotif = FloatingNotificationBanner(title: "Post uploaded! 😃", subtitle: "Your post will become visible once it is approved.", style: .success)
                uploadNotif.autoDismiss = false
                uploadNotif.dismissOnTap = true
                uploadNotif.dismissOnSwipeUp = true
                uploadNotif.show()
            } else {
                FloatingNotificationBanner(title: "Post uploaded! 😃", style: .success).show()
            }
        }.catch { err in
            uploadIndicator.dismiss()

            let errorIndicator = FloatingNotificationBanner(title: "Error 😵", subtitle: "\(err)", style: .danger)
            errorIndicator.autoDismiss = false
            errorIndicator.dismissOnSwipeUp = true
            errorIndicator.dismissOnTap = true
            errorIndicator.show()
            
            print("[MakePostViewController]: Attempted to delete uploaded post data after upload failure.")
            EntriesManager.deleteFailedPost(ofId: data["id"] as! String).catch { (err) in
                print("[MakePostViewController]: Post could not be deleted after deletion attempt.")
            }
            return
        }
    }

    @objc fileprivate func exitView() {
        self.dismiss(animated: true)
    }

    @objc fileprivate func dismissKeyboard() {
        view.endEditing(true)
    }

}
