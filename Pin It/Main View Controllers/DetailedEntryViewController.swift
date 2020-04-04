//
//  DetailedEntryViewController.swift
//  Pin It
//
//  Created by Joseph Jin on 1/12/20.
//  Copyright © 2020 AnimatorJoe. All rights reserved.
//

import UIKit
import Alamofire
import ImageSlideshow
import LayoutKit

class DetailedEntryViewController: UIViewController {

//    var titleLabel = UILabel()
//    var authorLabel = UILabel()
//    var descLabel = UILabel()
    var entry: Entry?
//    var slideshow = ImageSlideshow()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .dark
        view.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        
    }
    
    func useEntry(entry: Entry) {
        self.entry = entry
        let detailedPostLayout = DetailedPostLayout(title: entry.title, author: entry.username, desc: entry.description, id: entry.id, rootvc: self)
        detailedPostLayout.arrangement().makeViews(in: self.view)
    }

}
