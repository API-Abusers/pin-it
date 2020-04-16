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
    var entry: Entry?
    var onTap: ((_ e: Entry) -> Void)?
    
    @IBAction func showDetail(_ sender: Any) {
        guard let execute = onTap else { return }
        execute(self.entry!)
    }
    
    // cofigure behavior on top
    func onTap(execute: @escaping ((_ e: Entry) -> Void)) {
        self.onTap = execute
        addTapGestureRecognizer {
            self.onTap!(self.entry!)
        }
    }
    
    func configureCallout(_ viewModel: CalloutViewModel) {
        let viewModel = viewModel as! MiniEntryViewModel
        entry = viewModel.entry
        
        title.resizeAndDisplayText(text: entry!.username)
        body.resizeAndDisplayText(text: entry!.title)

        self.layer.cornerRadius = 5
        self.layer.masksToBounds = true
        
        var newFrame = self.frame
        newFrame.size.height = title.requiredHeight + body.requiredHeight + button.bounds.size.height + 42
        self.frame = newFrame
    }
    
}
