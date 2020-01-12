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
        var padding: CGFloat = 12
        
        
        scrollView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        
        // Setting up view layout
        formContainerStackView.axis = .vertical
        formContainerStackView.spacing = 25
        formContainerStackView.layoutMargins = .init(top: 25, left: 25, bottom: 0, right: 25)
        
        // Title field
        titleField = IndentedTextField(placeholder: "Title", padding: padding, cornerRadius: 5, backgroundColor: #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1), isSecureTextEntry: false)
        titleField.constrainHeight(50)
        titleField.font = .systemFont(ofSize: 25)
        formContainerStackView.addArrangedSubview(titleField)
        
        // Description field
        descField = LBTATextView()
        descField.backgroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        descField.font = .systemFont(ofSize: 20)
        descField.placeholder = "Add a description"
        descField.layer.cornerRadius = 5
        var p = CGFloat(padding)-descField.layer.cornerRadius
        descField.textContainerInset = UIEdgeInsets(top: p, left: p, bottom: p, right: p)
        descField.isEditable = true
        formContainerStackView.addArrangedSubview(descField)
        
        // Buttons
        formContainerStackView.addArrangedSubview(postButton)
        formContainerStackView.addArrangedSubview(exitButton)
    }
    
    
    @objc fileprivate func sendPost() {
        // make post request
        let data: [String: Any] = [
            "post": [
                "title" : titleField.text!,
                "description" : descField.text!
            ],
            "userLoc": [20, 20]
        ]
        
        print("attempting to send \(data)")
        
        Alamofire.request(URL(string: "http://localhost:3000")!,
                          method: .post,
                          parameters: data,
                          encoding: JSONEncoding.default)
        
    }

    @objc fileprivate func exitView() {
        self.dismiss(animated: true)
    }
    
    @objc fileprivate func dismissKeyboard() {
        view.endEditing(true)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
