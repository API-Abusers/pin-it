//
//  PopupViewController.swift
//  Pin It
//
//  Created by Joseph Jin on 4/17/20.
//  Copyright © 2020 AnimatorJoe. All rights reserved.
//

import UIKit
import MapKit

class PopupViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var itemsList: [Entry]!
    
    override func viewDidLoad() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        self.showAnimation()
    }
    
    func useAnnotations(annotations: [MKAnnotation]) {
        itemsList = [Entry]()
        annotations.forEach { (annotation) in
            if let annotation = annotation as? PinAnnotation {
                itemsList.append(annotation.e)
            }
        }
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

extension PopupViewController: UITableViewDelegate {
    
}

extension PopupViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        itemsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "pinCell") as! PinTableViewCell
        let e = itemsList[indexPath.row]
        
        cell.titleLable.font = .systemFont(ofSize: 18)
        cell.titleLable.resizeAndDisplayText(text: e.title)
        
        cell.authorLabel.font = .italicSystemFont(ofSize: 10)
        cell.authorLabel.textColor = .secondaryLabel
        cell.authorLabel.resizeAndDisplayText(text: e.username)
        
        return cell
    }
}

