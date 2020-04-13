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

public class DetailedPostLayout: InsetLayout<UIView> {

    init(_ entry: Entry, rootvc: UIViewController) {
        
        let titleLayout = LabelLayout(text: entry.title, font: UIFont.boldSystemFont(ofSize: 40))
        
        let editButtonLayout = ButtonLayout(type: .system, title: "", contentEdgeInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), alignment: .topTrailing, flexibility: Flexibility.inflexible) { button in
            button.setBackgroundImage(UIImage(systemName: "ellipsis.circle.fill"), for: .normal)
            button.tintColor = .white
            
            let alert = UIAlertController(title: nil, message: "Post Edit Options", preferredStyle: .actionSheet)
            
            // delete
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (action) in
                print("deletion?")
                
                let deletionAlert = UIAlertController(title: "Are you sure you want to delete your post?", message: "This action cannot be undone.", preferredStyle: .alert)
                
                let confirmDeletion = UIAlertAction(title: "Delete", style: .destructive) { (action) in
                    EntriesManager.deletePost(ofId: entry.id).done { _ in
                        rootvc.dismiss(animated: true)
                    }.catch { (err) in
                        print(err)
                        rootvc.dismiss(animated: true)
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
                print("edit post")
            }
            alert.addAction(editAction)
            
            // cancel
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
            alert.addAction(cancelAction)
            
            
            button.addTapGestureRecognizer {
                rootvc.present(alert, animated: true)
            }
            
        }
        
        let exitButtonLayout = ButtonLayout(type: .system, title: "", contentEdgeInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), alignment: .topTrailing, flexibility: Flexibility.inflexible) { button in
            button.setBackgroundImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
            button.tintColor = .white
            button.addTapGestureRecognizer { rootvc.dismiss(animated: true) }
        }
        
        let authorLayout = LabelLayout(text: entry.username, font: UIFont.italicSystemFont(ofSize: 15))
        let descLayout = LabelLayout(text: entry.desc, font: UIFont.systemFont(ofSize: 20))
        
        let imageSlideshow = SizeLayout<ImageSlideshow>(
            width: rootvc.view.frame.size.width - 50,
            height: rootvc.view.frame.size.width - 50,
            config: { slideshow in
                // Add ImageSlideShow
                slideshow.slideshowInterval = 5.0
                slideshow.pageIndicatorPosition = .init(horizontal: .center, vertical: .under)
                slideshow.contentScaleMode = UIViewContentMode.scaleAspectFill

                let pageControl = UIPageControl()
                pageControl.currentPageIndicatorTintColor = UIColor.lightGray
                pageControl.pageIndicatorTintColor = UIColor.black
                slideshow.pageIndicator = pageControl

                // Adding Spinner
                //slideshow.activityIndicator = DefaultActivityIndicator(style: .white, color: nil) // this doesn't appear to be working
                var spinner = UIActivityIndicatorView(style: .whiteLarge)
                spinner.translatesAutoresizingMaskIntoConstraints = false
                spinner.startAnimating()
                slideshow.addSubview(spinner)
                spinner.centerXAnchor.constraint(equalTo: slideshow.centerXAnchor).isActive = true
                spinner.centerYAnchor.constraint(equalTo: slideshow.centerYAnchor).isActive = true
                
                EntriesManager.getPostImages(ofEntry: entry).done { (images) in
                    var imgSource = [ImageSource]()
                    images.forEach { (img) in imgSource.append(ImageSource(image: img))}
                    slideshow.setImageInputs(imgSource)
                    
                    // adding gesture recognizer
                    slideshow.addTapGestureRecognizer {
                        slideshow.presentFullScreenControllerForIos13(from: rootvc)
                    }
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
