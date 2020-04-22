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

    var entry: Entry!
    var scrollView: UIScrollView!
    var shown = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        view.backgroundColor = .white
        view.isOpaque = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if(shown) { return }
        shown = true
        
        scrollView = UIScrollView(frame: CGRect(origin: CGPoint(x: 0, y: 0),
                                                size: CGSize(width: view.frame.width, height: view.frame.height)))
        view.addSubview(scrollView)
        
        let detailedPostLayout = DetailedPostLayout(entry, rootvc: self)
        let arrangment = detailedPostLayout.arrangement(width: self.view.bounds.width)
        scrollView.contentSize = CGSize(width: view.frame.width,
                                        height: arrangment.frame.size.height + 50)
        arrangment.makeViews(in: self.scrollView)
    }
    
    func useEntry(entry: Entry) {
        self.entry = entry
    }

}
