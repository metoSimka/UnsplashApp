//
//  ZoomTransitionDelegate.swift
//  UnsplashApp
//
//  Created by metoSimka on 24.10.2020.
//  Copyright © 2020 metoSimka. All rights reserved.
//

import Foundation
import UIKit



@objc protocol ZoomingViewController {
    var doubleTappedIndexPath: IndexPath? { get set }
    func zoomingImageView(for transition: ZoomTransitioningDelegate) -> UIImageView?
    func zoomingBackgroundView(for transiotion: ZoomTransitioningDelegate) -> UIView?
}

enum TransitionState {
    case initial
    case final
}

class ZoomTransitioningDelegate: NSObject {
    var transitionDuration = 0.5
    var operation: UINavigationController.Operation = .none
    private let zoomScale = CGFloat(15)
    private let backgroundScale = CGFloat(0.7)
    
    typealias ZoomingViews = (otherView: UIView?, imageView: UIView?)
    func configureViews(for state: TransitionState, containerView: UIView, backgroundViewController: UIViewController, viewsInBackground: ZoomingViews, viewsInForeground: ZoomingViews?, snapshotViews: ZoomingViews) {
        switch state {
        case .initial:
            backgroundViewController.view.transform = CGAffineTransform.identity
            backgroundViewController.view.alpha = 1
            guard let imageInBackground = viewsInBackground.imageView else {
                return
            }
            snapshotViews.imageView?.frame = containerView.convert(imageInBackground.frame, from: imageInBackground.superview)
        case .final:
            backgroundViewController.view.transform = CGAffineTransform(scaleX: backgroundScale, y: backgroundScale)
            backgroundViewController.view.alpha = 0
            let imageInForeground: UIView
            if let view = viewsInForeground?.imageView {
                imageInForeground = view
            } else {
                imageInForeground = UIView()
            }
            snapshotViews.imageView?.frame = containerView.convert(imageInForeground.frame, to: imageInForeground.superview)
        }
    }
}

extension ZoomTransitioningDelegate: UIViewControllerAnimatedTransitioning {
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let duration = transitionDuration(using: transitionContext)
        guard let fromViewController = transitionContext.viewController(forKey: .from) else {
            return
        }
        guard let toViewController = transitionContext.viewController(forKey: .to) else {
            return
        }
 
        let containerView = transitionContext.containerView
        var backgroundViewController = fromViewController
        var foregroundViewController = toViewController
        
        let contentMode: UIView.ContentMode
        if let mode = (foregroundViewController as? ZoomingViewController)?.zoomingImageView(for: self)?.contentMode {
            contentMode = mode
        } else {
            contentMode = .scaleAspectFit
        }
        if operation == .pop {
            backgroundViewController = toViewController
            foregroundViewController = fromViewController
        }
        let backgroundImageView = (backgroundViewController as? ZoomingViewController)?.zoomingImageView(for: self)

       let foregroundImageView = (foregroundViewController as? ZoomingViewController)?.zoomingImageView(for: self)
        
        let imageViewSnapshot = UIImageView(image: backgroundImageView?.image)
        
        imageViewSnapshot.contentMode = contentMode
        imageViewSnapshot.layer.masksToBounds = true
        imageViewSnapshot.clipsToBounds = true
        
        backgroundImageView?.isHidden = true
        foregroundImageView?.isHidden = true
        
        let foregroundViewBackgroundColor = foregroundViewController.view.backgroundColor
        foregroundViewController.view.backgroundColor = .clear
        containerView.backgroundColor = .white
        containerView.addSubview(backgroundViewController.view)
        containerView.addSubview(foregroundViewController.view)
        containerView.addSubview(imageViewSnapshot)
        
        var preTransitionState = TransitionState.initial
        var postTransitionState = TransitionState.final
        if operation == .pop {
            preTransitionState = .final
            postTransitionState = .initial
        }
        configureViews(for: preTransitionState, containerView: containerView, backgroundViewController: backgroundViewController, viewsInBackground: (backgroundImageView, backgroundImageView), viewsInForeground: (foregroundImageView, foregroundImageView), snapshotViews: (imageViewSnapshot, imageViewSnapshot))
        
        //
        foregroundViewController.view.layoutIfNeeded()
        
        UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: []) {
            
            self.configureViews(for: postTransitionState, containerView: containerView, backgroundViewController: backgroundViewController, viewsInBackground: (backgroundImageView, backgroundImageView), viewsInForeground: (foregroundImageView, foregroundImageView), snapshotViews: (imageViewSnapshot, imageViewSnapshot))
        } completion: { (finished) in
            backgroundViewController.view.transform = CGAffineTransform.identity
            imageViewSnapshot.removeFromSuperview()
            backgroundImageView?.isHidden = false
            foregroundImageView?.isHidden = false
            foregroundViewController.view.backgroundColor = foregroundViewBackgroundColor
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return transitionDuration
    }
}

extension ZoomTransitioningDelegate: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if fromVC is ZoomingViewController && toVC is ZoomingViewController {
            self.operation = operation
            return self
        } else {
            return nil
        }
    }
}
