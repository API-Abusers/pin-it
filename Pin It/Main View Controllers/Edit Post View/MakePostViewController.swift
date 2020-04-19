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

class MakePostViewController: FormViewController, NVActivityIndicatorViewable {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        self.isModalInPresentation = true
        createForm()
    }
    
    // MARK: Create Form
    func createForm() {
        form
            // Title and description fields
            +++ Section("Write a Post") 
            // Image selector
            <<< MultiImagePickerRow(fromController: .specific(self)) { row in
                row.descriptionTitle = "Select images"
                row.tag = "images"
                row.value = [.empty,.empty,.empty]
            }
            
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
            
            // Location selector
            +++ Section("Selection a Location")
            <<< LocationRow(){
                $0.title = "Location"
                $0.value = MapViewController.userLoc
                $0.tag = "location"
                $0.validationOptions = .validatesOnChange //2
            }
            
            // Button rows
            +++ Section()
            <<< ButtonRow { button in
                button.title = "Post"
            }
            .cellSetup { cell, row in
                cell.backgroundColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
                cell.tintColor = .white
            }
            .onCellSelection { cell, row in
                self.sendPost()
            }
            
            <<< ButtonRow { (row: ButtonRow) -> Void in
                row.title = "Exit"
            }
            .cellSetup{ cell, row in
                cell.backgroundColor = .systemRed
                cell.tintColor = .white
            }
            .onCellSelection { cell, row in
                self.exitView()
            }
    }
    
    // MARK: Sending Post
    @objc fileprivate func sendPost() {
        let user = Auth.auth().currentUser

        if !Connectivity.isConnectedToInternet {
            WarningPopup.issueWarningOnInternetConnection(vc: self)
            return
        }
        
        // unwrap user selections and check for completion
        guard let titleField = self.form.rowBy(tag: "title")!.baseValue as! String?,
            let descField = self.form.rowBy(tag: "desc")!.baseValue as! String?,
            let locField = self.form.rowBy(tag: "location")!.baseValue as! CLLocation?,
            let imageSlots = self.form.rowBy(tag: "images")!.baseValue as! [MultiImageTableCellSlot]? else {
            WarningPopup.issueWarningOnIncompletePost(vc: self)
            return
        }
        
        if(titleField.isEmpty || descField.isEmpty) {
            WarningPopup.issueWarningOnIncompletePost(vc: self)
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

        // make post request
        var data: [String: Any] = [
            "title" : titleField,
            "description" : descField,
            "userName": user?.displayName ?? "foo",
            "userLat": locField.coordinate.latitude,
            "userLong": locField.coordinate.longitude,
            "timestamp": Date(),
            "owner": Auth.auth().currentUser?.uid ?? "none",
            "approved": true
        ]

        var hasher = Hasher()
        hasher.combine(titleField)
        hasher.combine(descField)
        hasher.combine(user?.displayName)
        hasher.combine(Date())
        let hash = hasher.finalize()
        
        data["id"] = String(describing: hash)
        
//        startAnimating(nil, message: "uploading post", messageFont: nil, type: NVActivityIndicatorType.cubeTransition, color: nil, padding: nil, displayTimeThreshold: nil, minimumDisplayTime: nil, backgroundColor: nil, textColor: nil, fadeInAnimation: nil)
        
        
        self.dismiss(animated: true) { MapViewController.postPage = MakePostViewController() }
        
        let uploadIndicator = FloatingNotificationBanner(title: "Uploading Post", style: .info)
        uploadIndicator.show()
        
        firstly {
            EntriesManager.postEntry(data: data)
        }.then {_ in
            EntriesManager.attachImageFiles(files: imageSelection, addTo: data["id"] as! String)
        }.done { _ in
            uploadIndicator.dismiss()
            FloatingNotificationBanner(title: "Post uploaded! 😃", style: .success).show()
        }.catch { err in
            uploadIndicator.dismiss()

            let errorIndicator = FloatingNotificationBanner(title: "Error 😵", subtitle: "\(err)", style: .danger)
            errorIndicator.autoDismiss = false
            errorIndicator.show()
            
            let _ = EntriesManager.deletePost(ofId: data["id"] as! String)
//            let alert = UIAlertController(title: "Error", message: "\(err)", preferredStyle: UIAlertController.Style.alert)
//            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
//            self.present(alert, animated: true, completion: nil)
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
