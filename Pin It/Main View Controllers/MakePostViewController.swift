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

class MakePostViewController: FormViewController, NVActivityIndicatorViewable {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .dark
        view.backgroundColor = #colorLiteral(red: 0.1260543499, green: 0.1356953156, blue: 0.1489139211, alpha: 1)
        self.isModalInPresentation = true
        createForm()
    }
    
    // MARK: Create Form
    func createForm() {
        form
            // Title and description fields
            +++ Section() { section in
            section.header = {
            var header = HeaderFooterView<UIView>(.callback({
                let view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
                let title = UILabel(frame: CGRect(x: 16, y: 0, width: 500, height: 100))
                title.font = .boldSystemFont(ofSize: 40)
                title.text = "Make a Post"
                title.textColor = .white
                view.addSubview(title)
                return view
            }))
            header.height = { 100 }
            return header
            }()
        }
            <<< TextRow() { row in
                row.placeholder = "Title"
                row.tag = "title"
            }
            .cellSetup{ cell, row in
                cell.tintColor = .white
            }
            
            <<< TextAreaRow() { row in
                row.placeholder = "Description"
                row.tag = "desc"
            }
            .cellSetup { cell, row in
                cell.height = { 150 }
            }
            
            // Location selector
            +++ Section()
            <<< LocationRow(){
                $0.title = "Location"
                $0.value = MapViewController.userLoc
                $0.tag = "location"
                $0.validationOptions = .validatesOnChange //2
            }
            
            // Image selector
            +++ Section()
            <<< MultiImagePickerRow(fromController: .specific(self)) { row in
                row.placeholderImage = UIImage(color: .secondarySystemBackground)
                row.descriptionTitle = "Select images"
                row.tag = "images"
                row.cell.collectionView.backgroundColor = row.cell.backgroundColor
                row.value = [.empty,.empty,.empty]
            }
            
            
            // Button rows
            +++ Section()
            <<< ButtonRow { button in
                button.title = "Post"
            }
            .cellSetup { cell, row in
                cell.backgroundColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
                cell.tintColor = .white
            }
            .onCellSelection { cell, row in
                self.sendPost()
            }
            
            <<< ButtonRow { (row: ButtonRow) -> Void in
                row.title = "Exit"
            }
            .cellSetup{ cell, row in
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

        if !Connectivity.isConnectedToInternet {
            WarningPopup.issueWarningOnInternetConnection(vc: self)
            return
        }
        
        // unwrap user selections and check for completion
        guard let titleField = self.form.rowBy(tag: "title")!.baseValue as! String? else {
            WarningPopup.issueWarningOnIncompletePost(vc: self)
            return
        }
        
        guard let descField = self.form.rowBy(tag: "desc")!.baseValue as! String? else {
            WarningPopup.issueWarningOnIncompletePost(vc: self)
            return
        }
        
        guard let locField = self.form.rowBy(tag: "location")!.baseValue as! CLLocation? else {
            WarningPopup.issueWarningOnIncompletePost(vc: self)
            return
        }
        
        var imageSelection = [UIImage]()
        
        guard let imageSlots = self.form.rowBy(tag: "images")!.baseValue as! [MultiImageTableCellSlot]? else {
            WarningPopup.issueWarningOnIncompletePost(vc: self)
            return
        }
        
        for i in imageSlots {
            switch i {
            case .image(let img):
                imageSelection.append(img)
            default:
                continue
            }
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
            "userLong": locField.coordinate.longitude
        ]

        var hasher = Hasher()
        hasher.combine(titleField)
        hasher.combine(descField)
        hasher.combine(user?.displayName)
        hasher.combine(Date())
        let hash = hasher.finalize()
        
        data["pinId"] = String(describing: hash)
        startAnimating(nil, message: "uploading post", messageFont: nil, type: NVActivityIndicatorType.cubeTransition, color: nil, padding: nil, displayTimeThreshold: nil, minimumDisplayTime: nil, backgroundColor: nil, textColor: nil, fadeInAnimation: nil)
        
        firstly {
            EntriesManager.postEntry(data: data)
        }.then {_ in
            EntriesManager.attachImageFiles(files: imageSelection, addTo: data["pinId"] as! String)
        }.done { _ in
            self.stopAnimating()
            self.dismiss(animated: true) {
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                (appDelegate.mapVC as! MapViewController).updateEntriesOnMap()
                self.form.removeAll()
                MapViewController.postPage = MakePostViewController()
            }
        }.catch { err in
            self.stopAnimating()
            let alert = UIAlertController(title: "Error", message: "\(err)", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
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
