//
//  MiniEntryView.swift
//  Pin It
//
//  Created by Joseph Jin on 1/10/20.
//  Copyright © 2020 AnimatorJoe. All rights reserved.
//

import Foundation
import UIKit
import MapViewPlus

class MiniEntryView: UIView, CalloutViewPlus {
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var body: UILabel!
    @IBOutlet weak var button: UIButton!
    var rootController: MapViewController?
    var entry: Entry?
    
    @IBAction func showDetail(_ sender: Any) {
        rootController!.showDetail(entry: entry!)
    }
    
    func configureCallout(_ viewModel: CalloutViewModel) {
        let viewModel = viewModel as! MiniEntryViewModel
        entry = viewModel.entry
        
        title.text = viewModel.title
        body.text = viewModel.body

        self.layer.cornerRadius = 5
        self.layer.masksToBounds = true
        
        var newFrame = self.frame
        newFrame.size.height = title.frame.height + body.frame.height + button.bounds.size.height + 60
        self.frame = newFrame
    }
}
