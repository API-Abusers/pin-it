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

public class DetailedPostLayout: InsetLayout<UIView> {

    init(_ entry: Entry, rootvc: UIViewController) {
        
        let titleLayout = LabelLayout(text: entry.title, font: UIFont.boldSystemFont(ofSize: 40))
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
                }.finally {
                    spinner.stopAnimating()
                }
            }
        )
            
        super.init(
            insets: UIEdgeInsets(top: 25, left: 25, bottom: 0, right: 25),
            sublayout: StackLayout(
                axis: .vertical,
                spacing: 25,
                sublayouts: [titleLayout, authorLayout, imageSlideshow, descLayout]
            )
        )
    
    }   
}
