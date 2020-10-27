//
//  ViewModeViewController.swift
//  UnsplashApp
//
//  Created by metoSimka on 24.10.2020.
//  Copyright © 2020 metoSimka. All rights reserved.
//

import UIKit

struct DetailImageModel {
    var imageURLs: ImageURLs?
    var thumbImage: UIImage?
    var qualityImage: UIImage?
    
    static func initArray(fromURLs urls: [ImageURLs]) -> [DetailImageModel] {
        var detailImageArray: [DetailImageModel] = []
        for url in urls {
            let detailImage = DetailImageModel(imageURLs: url, thumbImage: nil, qualityImage: nil)
            detailImageArray.append(detailImage)
        }
        return detailImageArray
    }
    
    static func initArray(fromThumbnailEntities entities: [Thumbnail]) -> [DetailImageModel] {
        var detailImageArray: [DetailImageModel] = []
        for entity in entities {
            var thumbImage: UIImage?
            var qualityImage: UIImage?
            if let thumbImageData = entity.imageData {
                thumbImage = UIImage(data: thumbImageData)
            }
            if let qualityImageData = entity.hResolution?.imageData {
                qualityImage = UIImage(data: qualityImageData)
            }
            
            let detailImage = DetailImageModel(imageURLs: nil, thumbImage: thumbImage, qualityImage: qualityImage)
            detailImageArray.append(detailImage)
        }
        return detailImageArray
    }
}

class DetailViewModeViewController: UIViewController {

    private var images: [DetailImageModel] = []
    private var currentIndex: IndexPath
    private var rootVC: UIViewController
    private let zoomTransition = ZoomTransitioningDelegate()
    internal var doubleTappedIndexPath: IndexPath?
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var imageView: UIImageView!
    
    init(images: [DetailImageModel], selectedIndex: IndexPath, rootVC: UIViewController) {
        self.images = images
        self.currentIndex = selectedIndex
        self.rootVC = rootVC
        super.init(nibName: "DetailViewModeViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        self.images = []
        self.currentIndex = IndexPath()
        self.rootVC = UIViewController()
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        self.collectionView.isHidden = true
        self.automaticallyAdjustsScrollViewInsets = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.delegate = self
        self.collectionView.scrollToItem(at: currentIndex, at: .centeredHorizontally, animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.collectionView.scrollToItem(at: currentIndex, at: .centeredHorizontally, animated: false)
        imageView.isHidden = true
        self.collectionView.isHidden = false
    }
    
    private func setupCollectionView() {
        collectionView.register( UINib(nibName: "DetailViewModeCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "DetailViewModeCollectionViewCell")
        collectionView.dataSource = self
        collectionView.delegate = self
    }
}

extension DetailViewModeViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DetailViewModeCollectionViewCell", for: indexPath) as? DetailViewModeCollectionViewCell else {
            return UICollectionViewCell()
        }
        let imageModel = images[indexPath.row]
        cell.setup(imageModel)
        cell.delegate = self
        return cell
    }
}

extension DetailViewModeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

extension DetailViewModeViewController: UICollectionViewDelegate {
}

extension DetailViewModeViewController: ZoomingViewController {
    
    func zoomingBackgroundView(for transiotion: ZoomTransitioningDelegate) -> UIView? {
        return nil
    }
    
    func zoomingImageView(for transition: ZoomTransitioningDelegate) -> UIImageView? {
        if let cell = collectionView.cellForItem(at: currentIndex) as? DetailViewModeCollectionViewCell {
            return cell.imageView
        } else {
            return imageView
        }
    }
}

extension DetailViewModeViewController: ImageCellDelegate {
    func doubleTapCell(_ cell: ImageCollectionViewCell) {
        guard let index = collectionView.indexPath(for: cell) else {
            return
        }
        self.collectionView.isHidden = true
        self.currentIndex = index
        if let searchVC = rootVC as? ZoomingViewController {
            searchVC.doubleTappedIndexPath = currentIndex
        }
        navigationController?.popViewController(animated: true)
    }
}

extension DetailViewModeViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.zoomTransition.operation = operation
        return zoomTransition
    }
}
