//
//  DetailedPostView.swift
//  Pin It
//
//  Created by Joseph Jin on 4/2/20.
//  Copyright © 2020 AnimatorJoe. All rights reserved.
//

import UIKit
import LayoutKit
import ImageSlideshow
import PromiseKit
import Firebase
import NotificationBannerSwift

public class DetailedPostLayout: InsetLayout<UIView> {

    init(_ entry: Entry, rootvc: UIViewController) {
        
        let titleLayout = LabelLayout(text: entry.title, font: UIFont.boldSystemFont(ofSize: 40))
        
        let editButtonLayout = SizeLayout<UIButton>(width: 40, height: 40, alignment: .topTrailing, flexibility: Flexibility.inflexible) { button in
            button.setBackgroundImage(UIImage(systemName: "ellipsis.circle"), for: .normal)
            button.tintColor = .systemGray4
            button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            
            let alert = UIAlertController(title: nil, message: "Post Edit Options", preferredStyle: .actionSheet)
            
            // delete
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (action) in
                print("deletion?")
                
                let deletionAlert = UIAlertController(title: "Are you sure you want to delete your post?", message: "This action cannot be undone.", preferredStyle: .alert)
                
                if let popoverPresentationController = deletionAlert.popoverPresentationController {
                    popoverPresentationController.sourceView = rootvc.view
                    popoverPresentationController.sourceRect = CGRect(x: rootvc.view.bounds.midX, y: rootvc.view.bounds.midY, width: 0, height: 0)
                    popoverPresentationController.permittedArrowDirections = .init(rawValue: 0)
                }
                
                let confirmDeletion = UIAlertAction(title: "Delete", style: .destructive) { (action) in

                    rootvc.dismiss(animated: true)
                    
                    EntriesManager.deletePost(entry).done { _ in
                        FloatingNotificationBanner(title: "Post deleted!", style: .success).show()
                    }.catch { (err) in
                        let errorIndicator = FloatingNotificationBanner(title: "Post could not be deleted:", subtitle: "\(err)", style: .danger)
                        errorIndicator.autoDismiss = false
                        errorIndicator.dismissOnSwipeUp = true
                        errorIndicator.dismissOnTap = true
                        errorIndicator.show()
                    }
                }
                deletionAlert.addAction(confirmDeletion)
                
                let cancelDeletion = UIAlertAction(title: "Cancel", style: .cancel)
                deletionAlert.addAction(cancelDeletion)
                
                rootvc.present(deletionAlert, animated: true)
            }
            alert.addAction(deleteAction)
            
            // edit
            let editAction = UIAlertAction(title: "Edit", style: .default) { (action) in
                let editvc = EditPostViewController()
                editvc.useEntry(entry)
                editvc.onEditComplete { rootvc.dismiss(animated: true) }
                rootvc.present(editvc, animated: true)
            }
            alert.addAction(editAction)
            
            // cancel
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
            alert.addAction(cancelAction)
            
            
            button.addTapGestureRecognizer {
                if let popoverPresentationController = alert.popoverPresentationController {
                    popoverPresentationController.sourceView = rootvc.view
                    popoverPresentationController.sourceRect = CGRect(x: rootvc.view.bounds.midX, y: rootvc.view.bounds.midY, width: 0, height: 0)
                    popoverPresentationController.permittedArrowDirections = .init(rawValue: 0)
                }
                
                rootvc.present(alert, animated: true)
            }
            
        }
        
        let exitButtonLayout = SizeLayout<UIButton>(width: 40, height: 40, alignment: .topTrailing, flexibility: Flexibility.inflexible) { button in
            button.setBackgroundImage(UIImage(systemName: "xmark.circle"), for: .normal)
            button.tintColor = .systemGray4
            button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            button.addTapGestureRecognizer { rootvc.dismiss(animated: true) }
        }
        
        let authorLayout = LabelLayout(text: entry.username, font: UIFont.italicSystemFont(ofSize: 15)) { label in
            label.textColor = .secondaryLabel
        }
        let descLayout = LabelLayout(text: entry.desc, font: UIFont.systemFont(ofSize: 20))
        
        let imageSlideshow = SizeLayout<ImageSlideshow>(
            width: rootvc.view.frame.size.width - 50,
            height: rootvc.view.frame.size.width - 50,
            config: { slideshow in
                // Add ImageSlideShow
                slideshow.backgroundColor = .systemGray5
                slideshow.slideshowInterval = 5.0
                slideshow.pageIndicatorPosition = .init(horizontal: .center, vertical: .under)
                slideshow.contentScaleMode = UIViewContentMode.scaleAspectFill

                let pageControl = UIPageControl()
                pageControl.currentPageIndicatorTintColor = UIColor.lightGray
                pageControl.pageIndicatorTintColor = UIColor.black
                slideshow.pageIndicator = pageControl

                // Adding Spinner
                //slideshow.activityIndicator = DefaultActivityIndicator(style: .white, color: nil) // this doesn't appear to be working
                let spinner = UIActivityIndicatorView(style: .gray)
                spinner.translatesAutoresizingMaskIntoConstraints = false
                spinner.startAnimating()
                slideshow.addSubview(spinner)
                spinner.centerXAnchor.constraint(equalTo: slideshow.centerXAnchor).isActive = true
                spinner.centerYAnchor.constraint(equalTo: slideshow.centerYAnchor).isActive = true
                
                EntriesManager.getPostImages(ofEntry: entry).done { (images) in
                    guard let images = images else {
                        // if there are no images
                        slideshow.backgroundColor = #colorLiteral(red: 0.9216559553, green: 0.9216559553, blue: 0.9216559553, alpha: 1)
                        let label = UILabel(text: "no image(s) found", font: .italicSystemFont(ofSize: 20), textColor: .secondaryLabel, textAlignment: .center, numberOfLines: 1)
                        label.frame = CGRect(x: 10, y: 30, width: 200, height: 25)
                        label.translatesAutoresizingMaskIntoConstraints = false
                        slideshow.addSubview(label)
                        label.centerXAnchor.constraint(equalTo: slideshow.centerXAnchor).isActive = true
                        label.centerYAnchor.constraint(equalTo: slideshow.centerYAnchor).isActive = true
                        return
                    }
                    
                    var imgSource = [ImageSource]()
                    images.forEach { (img) in imgSource.append(ImageSource(image: img))}
                    slideshow.setImageInputs(imgSource)
                    
                    // adding gesture recognizer
                    slideshow.addTapGestureRecognizer {
                        slideshow.presentFullScreenControllerForIos13(from: rootvc)
                    }
                    slideshow.backgroundColor = .clear
                }.catch { (err) in
                    print("[DetailedPostLayout] Error while loading images: \(err)")
                    spinner.stopAnimating()
                }.finally {
                    spinner.stopAnimating()
                }
            }
        )
        
        var topLayout: [Layout] = [titleLayout, exitButtonLayout]
        let uid = Auth.auth().currentUser?.uid ?? "none"
        if (entry.owner == uid) {
            topLayout = [titleLayout, editButtonLayout, exitButtonLayout]
        }
            
        super.init(
            insets: UIEdgeInsets(top: 25, left: 25, bottom: 0, right: 25),
            sublayout: StackLayout(
                axis: .vertical,
                spacing: 25,
                sublayouts: [
                    StackLayout(axis: .horizontal, spacing: 10, sublayouts: topLayout),
                    authorLayout,
                    imageSlideshow,
                    descLayout]
            )
        )
    
    }   
}
