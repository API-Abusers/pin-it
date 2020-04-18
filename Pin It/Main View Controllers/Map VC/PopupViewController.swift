//
//  PopupViewController.swift
//  Pin It
//
//  Created by Joseph Jin on 4/17/20.
//  Copyright © 2020 AnimatorJoe. All rights reserved.
//

import UIKit

class PopupViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        self.view.addTapGestureRecognizer { self.removeAnimation() }
        self.showAnimation()
    }

    @IBAction func exit(_ sender: Any) {
        self.removeAnimation()
    }
    
    func showAnimation() {
        self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        self.view.alpha = 0
        UIView.animate(withDuration: 0.25) {
            self.view.alpha = 1
            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        }
    }
    
    func removeAnimation() {
        UIView.animate(withDuration: 0.25, animations: {
            self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.view.alpha = 0
        }) { finished in
            if (finished) { self.view.removeFromSuperview() }
        }
    }
    
}
