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

class EditPostViewController: FormViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .dark
        view.backgroundColor = #colorLiteral(red: 0.1260543499, green: 0.1356953156, blue: 0.1489139211, alpha: 1)
        self.isModalInPresentation = true
        createForm()
        // Do any additional setup after loading the view.
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
                row.placeholder = ""
                row.tag = "title"
            }
            .cellSetup{ cell, row in
                cell.tintColor = .white
            }
            
            <<< TextAreaRow() { row in
                row.placeholder = "Write a description..."
                row.tag = "desc"
            }
            .cellSetup { cell, row in
                cell.height = { 150 }
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
//                self.sendPost()
            }
            
            <<< ButtonRow { (row: ButtonRow) -> Void in
                row.title = "Exit"
            }
            .cellSetup{ cell, row in
                cell.backgroundColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
                cell.tintColor = .white
            }
            .onCellSelection { cell, row in
                self.dismiss(animated: true)
            }
    }

}
