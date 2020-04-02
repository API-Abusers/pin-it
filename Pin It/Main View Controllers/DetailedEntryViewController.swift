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
    var lineView = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 1))
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
        titleLabel = UILabel(text: entry?.title, font: UIFont.boldSystemFont(ofSize: 40), textColor: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), textAlignment: .natural, numberOfLines: 0)
        titleLabel.resizeAndDisplayText(text: entry!.title)
        formContainerStackView.addArrangedSubview(titleLabel)
        
        // Author label
        authorLabel = UILabel(text: entry?.username, font: UIFont.italicSystemFont(ofSize: 15), textColor: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), textAlignment: .natural, numberOfLines: 0)
        authorLabel.resizeAndDisplayText(text: entry!.username)
        formContainerStackView.addArrangedSubview(authorLabel)
        
        // Description label
        descLabel = UILabel(text: entry?.description, font: UIFont.systemFont(ofSize: 20), textColor: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), textAlignment: .natural, numberOfLines: 0)
        descLabel.resizeAndDisplayText(text: entry!.description)
        formContainerStackView.addArrangedSubview(descLabel)
        
    }
    
    func useEntry(entry: Entry) {
        self.entry = entry
        titleLabel.resizeAndDisplayText(text: entry.title)
        authorLabel.resizeAndDisplayText(text: entry.username)
        descLabel.resizeAndDisplayText(text: entry.description)
        EntriesManager.getPostImages(ofId: entry.id).done { (images) in
            for image in images {
                let imageView = UIImageView(image: image)
                self.formContainerStackView.addArrangedSubview(imageView)
            }
        }
    }

}
