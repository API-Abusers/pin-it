//
//  UILabelExtension.swift
//  Pin It
//
//  Created by Joseph Jin on 1/12/20.
//  Copyright © 2020 AnimatorJoe. All rights reserved.
//

import Foundation
import UIKit

extension UILabel {
    func resizeAndDisplayText(text message: String) {
        //set the text and style if any.
        self.text = message
        self.numberOfLines = 0
        let maximumLabelSize: CGSize = CGSize(width: 280, height: 9999)
        let expectedLabelSize: CGSize = self.sizeThatFits(maximumLabelSize)
        // create a frame that is filled with the UILabel frame data
        var newFrame: CGRect = self.frame
        // resizing the frame to calculated size
        newFrame.size.height = expectedLabelSize.height
        // put calculated frame into UILabel frame
        self.frame = newFrame
    }
    
}
