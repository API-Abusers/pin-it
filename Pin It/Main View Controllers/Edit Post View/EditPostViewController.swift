//
//  EditPostViewController.swift
//  Pin It
//
//  Created by Joseph Jin on 4/13/20.
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

class EditPostViewController: FormViewController {
    
    var e: Entry!
    var completion: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        self.isModalInPresentation = true
        createForm()
        // Do any additional setup after loading the view.
    }
    
    // MARK: Get Entry
    func useEntry(_ e: Entry) {
        self.e = e
    }
    
    // MARK: On Edit Complete
    func onEditComplete(_ completion : @escaping (() -> Void)) {
        self.completion = completion
    }

    // MARK: Create Form
    func createForm() {
        form
            // Title and description fields
            +++ Section("Edit Title")
            <<< TextRow() { row in
                row.placeholder = "Write a title..."
                row.value = e.title
                row.tag = "title"
            }
            .cellSetup{ cell, row in
            }
            
            +++ Section("Edit Description")
            <<< TextAreaRow() { row in
                row.placeholder = "Write a description..."
                row.value = e.desc
                row.tag = "desc"
            }
            .cellSetup { cell, row in
                cell.height = { 150 }
            }
            
            +++ Section("Edit Location")
            <<< LocationRow(){
                $0.title = "Location"
                $0.value = CLLocation(latitude: e.location[0], longitude: e.location[1])
                $0.tag = "location"
                $0.validationOptions = .validatesOnChange //2
            }
            
            // Button rows
            +++ Section()
            <<< ButtonRow { button in
                button.title = "Save"
            }
            .cellSetup { cell, row in
                cell.backgroundColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
                cell.tintColor = .white
            }
            .onCellSelection { cell, row in
                guard let titleField = self.form.rowBy(tag: "title")!.baseValue as! String?,
                    let descField = self.form.rowBy(tag: "desc")!.baseValue as! String?,
                    let locField = self.form.rowBy(tag: "location")!.baseValue as! CLLocation? else {
                    WarningPopup.issueWarningOnIncompletePost(vc: self)
                    return
                }
                self.dismiss(animated: true) {
                    if let completion = self.completion { completion() }
                }
                EntriesManager.editPostFields(ofPost: self.e, writes: ["title" : titleField,
                                                                       "description" : descField,
                                                                       "userLat": locField.coordinate.latitude,
                                                                       "userLong": locField.coordinate.longitude]).done { _ in
                    FloatingNotificationBanner(title: "Post updated! 😃", style: .success).show()
                    self.dismiss(animated: true) {
                        if let completion = self.completion { completion() }
                    }
                }.catch { (err) in
                    let errorIndicator = FloatingNotificationBanner(title: "Post could not be edited:", subtitle: "\(err)", style: .danger)
                    errorIndicator.autoDismiss = false
                    errorIndicator.show()
                    
                    WarningPopup.issueWarning(title: "Error", description: err as! String, vc: self)
                }
            }
            
            <<< ButtonRow { (row: ButtonRow) -> Void in
                row.title = "Cancel"
            }
            .cellSetup{ cell, row in
                cell.backgroundColor = .systemRed
                cell.tintColor = .white
            }
            .onCellSelection { cell, row in
                self.dismiss(animated: true)
            }
    }

}
