//
//  MakePostViewController.swift
//  Pin It
//
//  Created by Joseph Jin on 1/9/20.
//  Copyright © 2020 AnimatorJoe. All rights reserved.
//

import UIKit
import LBTATools
import LBTAComponents
import Alamofire
import Firebase
import GoogleSignIn

class MakePostViewController: LBTAFormController, UITextViewDelegate {

    var titleField = IndentedTextField()
    var descField = LBTATextView()
    let postButton = UIButton(title: "Post", titleColor: .white, font: .boldSystemFont(ofSize: 16), backgroundColor: #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1), target: self, action: #selector(sendPost))
    let exitButton = UIButton(title: "Exit", titleColor: .white, font: .boldSystemFont(ofSize: 16), backgroundColor: #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1), target: self, action: #selector(exitView))
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .dark
        view.backgroundColor = #colorLiteral(red: 0.1260543499, green: 0.1356953156, blue: 0.1489139211, alpha: 1)
        self.isModalInPresentation = true
        
        scrollView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        
        // Setting up view layout
        formContainerStackView.axis = .vertical
        formContainerStackView.spacing = 25
        formContainerStackView.layoutMargins = .init(top: 25, left: 25, bottom: 0, right: 25)
        
        // Title label
        let titleLabel = UILabel(text: "Write a Post", font: UIFont.boldSystemFont(ofSize: 40), textColor: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), textAlignment: .natural, numberOfLines: 0)
        formContainerStackView.addArrangedSubview(titleLabel)
        
        // Setting up text fields
        initInputFields()
        formContainerStackView.addArrangedSubview(titleField)
        formContainerStackView.addArrangedSubview(descField)
        
        // Buttons
        formContainerStackView.addArrangedSubview(postButton)
        formContainerStackView.addArrangedSubview(exitButton)
    }
    
    // MARK: Init Input Fields
    func initInputFields() {
        let padding: CGFloat = 8
        // Title field
        titleField = IndentedTextField(placeholder: "Title", padding: padding, cornerRadius: 5, backgroundColor: #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1), isSecureTextEntry: false)
        titleField.constrainHeight(50)
        titleField.font = .systemFont(ofSize: 25)
        
        // Description field
        descField = LBTATextView()
        descField.backgroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        descField.font = .systemFont(ofSize: 25)
        descField.placeholder = "Add a description"
        descField.layer.cornerRadius = 5
        descField.textContainerInset = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
        descField.isEditable = true
        
    }
    
    // MARK: Sending Post
    @objc fileprivate func sendPost() {
        let user = Auth.auth().currentUser
        
        // stop empty posts from being sent
        if(titleField.text!.isEmpty || descField.text.isEmpty) {
            let alert = UIAlertController(title: "Incomplete Post", message: "Please finish your post", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        // make post request
        var data: [String: Any] = [
            "pinId": "0",
            "title" : titleField.text!,
            "description" : descField.text!,
            "userName": user?.displayName ?? "foo",
            "userLat": 21,
            "userLong": 21
        ]
        
        var hasher = Hasher()
        hasher.combine(titleField.text!)
        hasher.combine(descField.text!)
        hasher.combine(user?.displayName)
        hasher.combine(Date())
        let hash = hasher.finalize()
        data["pinId"] = String(describing: hash)
        
        print("[MakePostViewController] attempting to send: \n\(data)")
        Alamofire.request(URL(string: QueryConfig.url.rawValue + QueryConfig.postEndPoint.rawValue)!,
                          method: .post,
                          parameters: data,
                          encoding: JSONEncoding.default)
        .response { (res) in
            print("[MakePostViewController] got server response \(res)")
            self.titleField.text = ""
            self.descField.text = ""
            self.dismiss(animated: true)
        }
        
    }

    @objc fileprivate func exitView() {
        self.dismiss(animated: true)
    }
    
    @objc fileprivate func dismissKeyboard() {
        view.endEditing(true)
    }

}
