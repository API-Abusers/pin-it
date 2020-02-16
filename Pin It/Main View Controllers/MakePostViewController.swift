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

class MakePostViewController: FormViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .dark
        view.backgroundColor = #colorLiteral(red: 0.1260543499, green: 0.1356953156, blue: 0.1489139211, alpha: 1)
        self.isModalInPresentation = true
        
        form +++ Section("Write A Post")
            <<< TextRow() { row in
                row.placeholder = "Title"
                row.tag = "title"
            }.cellSetup{ cell, row in
                cell.tintColor = .white
            }
            
            <<< TextAreaRow() { row in
                row.placeholder = "Description"
                row.tag = "desc"
            }
            
            <<< ButtonRow { button in
                button.title = "Post"
            }.cellSetup { cell, row in
                cell.backgroundColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
                cell.tintColor = .white
            }
            .onCellSelection { cell, row in
                self.sendPost()
            }
            
            <<< ButtonRow { (row: ButtonRow) -> Void in
                row.title = "Exit"
            }.cellSetup{ cell, row in
                cell.backgroundColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
                cell.tintColor = .white
            }
            .onCellSelection { cell, row in
                self.exitView()
            }
        
    }
    
    // MARK: Sending Post
    @objc fileprivate func sendPost() {
        let user = Auth.auth().currentUser

        guard let titleField = self.form.rowBy(tag: "title")!.baseValue as! String? else {
            self.issueWarning()
            return
        }
        
        guard let descField = self.form.rowBy(tag: "desc")!.baseValue as! String? else {
            self.issueWarning()
            return
        }
        
        
        // stop empty posts from being sent
        if(titleField.isEmpty || descField.isEmpty) {
            issueWarning()
            return
        }

        // make post request
        var data: [String: Any] = [
            "pinId": "0",
            "title" : titleField,
            "description" : descField,
            "userName": user?.displayName ?? "foo",
            "userLat": 21,
            "userLong": 21
        ]

        var hasher = Hasher()
        hasher.combine(titleField)
        hasher.combine(descField)
        hasher.combine(user?.displayName)
        hasher.combine(Date())
        let hash = hasher.finalize()
        data["pinId"] = String(describing: hash)

        CLLocationManager.requestLocation().done { (arr) in
            let loc = arr[0]
            data["userLat"] = loc.coordinate.latitude
            data["userLong"] = loc.coordinate.longitude

            EntriesManager.postEntry(data: data)
            .done { (res) in
                print("Response after post")
                print(res)
                let titleRow = self.form.rowBy(tag: "title") as! TextRow
                titleRow.value = ""
                let descRow = self.form.rowBy(tag: "desc") as! TextAreaRow
                descRow.value = ""
                self.dismiss(animated: true) {
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    (appDelegate.mapVC as! MapViewController).updateEntriesOnMap()
                }
            }
            .catch { (err) in
                let alert = UIAlertController(title: "Error", message: "\(err)", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }

        }

    }
    
    // MARK: Issue Warning
    func issueWarning() {
        let alert = UIAlertController(title: "Incomplete Post", message: "Please finish your post", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    @objc fileprivate func exitView() {
        self.dismiss(animated: true)
    }

    @objc fileprivate func dismissKeyboard() {
        view.endEditing(true)
    }

}
