// from https://github.com/zvonicek/ImageSlideshow/issues/354

import Foundation
import ImageSlideshow

extension ImageSlideshow {
    @discardableResult
    open func presentFullScreenControllerForIos13(from controller: UIViewController) -> FullScreenSlideshowViewController {
        let fullscreen = FullScreenSlideshowViewController()
        fullscreen.pageSelected = {[weak self] (page: Int) in
            self?.setCurrentPage(page, animated: false)
        }

        fullscreen.initialPage = currentPage
        fullscreen.inputs = images
        // slideshowTransitioningDelegate = ZoomAnimatedTransitioningDelegate(slideshowView: self, slideshowController: fullscreen)
        fullscreen.transitioningDelegate = slideshowTransitioningDelegate
        fullscreen.modalPresentationStyle = .fullScreen
        controller.present(fullscreen, animated: true, completion: nil)

        return fullscreen
    }
}
