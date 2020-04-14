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

    var entry: Entry?
    var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .dark
        view.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        
        scrollView = UIScrollView(frame: CGRect(origin: CGPoint(x: 0, y: 0),
                                                size: CGSize(width: view.frame.width, height: view.frame.height)))
        view.addSubview(scrollView)
    }
    
    func useEntry(entry: Entry) {
        self.entry = entry
        let detailedPostLayout = DetailedPostLayout(entry, rootvc: self)
        
        let arrangment = detailedPostLayout.arrangement(width: self.view.frame.width)
        scrollView.contentSize = CGSize(width: view.frame.width, height: arrangment.frame.size.height + 50)
        arrangment.makeViews(in: self.scrollView)
    }

}
