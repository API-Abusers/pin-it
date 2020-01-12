//
//  DetailedEntryViewController.swift
//  Pin It
//
//  Created by Joseph Jin on 1/12/20.
//  Copyright © 2020 AnimatorJoe. All rights reserved.
//

import UIKit
import LBTATools
import Alamofire

class DetailedEntryViewController: LBTAFormController {

    var titleLabel = UILabel()
    var authorLabel = UILabel()
    var descLabel = UILabel()
    var entry: Entry?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .dark
        view.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        
        // Setting up view layout
        formContainerStackView.axis = .vertical
        formContainerStackView.spacing = 25
        formContainerStackView.layoutMargins = .init(top: 25, left: 25, bottom: 0, right: 25)
        
        // Title label
        titleLabel = UILabel(text: entry?.title, font: UIFont.boldSystemFont(ofSize: 30), textColor: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), textAlignment: .natural, numberOfLines: 1)
        formContainerStackView.addArrangedSubview(titleLabel)
        
        // Author label
        authorLabel = UILabel(text: entry?.username, font: UIFont.italicSystemFont(ofSize: 15), textColor: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), textAlignment: .natural, numberOfLines: 1)
        formContainerStackView.addArrangedSubview(authorLabel)
        
        // Description label
        descLabel = UILabel(text: entry?.description, font: UIFont.systemFont(ofSize: 20), textColor: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), textAlignment: .natural, numberOfLines: 10)
        formContainerStackView.addArrangedSubview(descLabel)
        
    }

}
