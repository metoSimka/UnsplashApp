//
//  SearchViewController.swift
//  UnsplashApp
//
//  Created by metoSimka on 19.10.2020.
//  Copyright © 2020 metoSimka. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {
    
    // MARK: - Public constants
    
    // MARK: - Public variables

    // MARK: - IBOutlets
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - Private constants
    private let maxPage = 100
    
    // MARK: - Private variables
    static private let perPage = 12

    private var currentPage = 1
    private var images: [ImageURLs] = []
    private var currentQuery: String?
    
    private var selectedIndexPath: IndexPath?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        RequestService.shared.addSearchTask(nil, currentPage: 1) { (imageDatas) in
            self.updateImages(imageDatas)
        }
    }
    
     // MARK: - IBActions
    @IBAction func search(_ sender: UIButton) {
        resetVariables()
        currentQuery = getQueryFromTextField()
        RequestService.shared.stopAllTasks()
        searchImages(searchText: currentQuery, page: currentPage)
        self.collectionView.reloadData()
    }
    
    // MARK: - Public methods
    public func syncSelectedIndexPath(indexPath: IndexPath) {
        self.selectedIndexPath = indexPath
    }
    
    // MARK: - Private methods
    private func resetVariables() {
        self.currentPage = 1
        self.images = []
        ImageCache.shared.cache.removeAllObjects()
    }
    
    private func getQueryFromTextField() -> String? {
        guard let text = textField.text else {
            return nil
        }
        let filteredText = text.replacingOccurrences(of: " ", with: "")
        if filteredText == "" {
            return nil
        }
        return filteredText
    }
    
    private func searchImages(searchText: String?, page: Int) {
        RequestService.shared.addSearchTask(currentQuery, currentPage: page) { imageDatas in
            self.updateImages(imageDatas)
            RequestService.shared.executeTaskFromQueue()
        }
    }
    
    private func updateImages(_ imageDatas: [ImageURLs]) {
        for imageData in imageDatas {
            let contains = images.contains(where: {$0 == imageData})
            guard contains == false else {
                return
            }
            self.images.append(imageData)
            self.collectionView.insertItems(at: [IndexPath(row: self.images.count - 1, section: 0)])
        }
    }

    private func setupCollectionView() {
        collectionView.register( UINib(nibName: "ImageCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ImageCollectionViewCell")
        collectionView.dataSource = self
        collectionView.delegate = self
    }
}

// MARK: - Protocol Conformance
extension SearchViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCollectionViewCell", for: indexPath) as?  ImageCollectionViewCell else {
            return UICollectionViewCell()
        }
        let imageModel = images[indexPath.row]
        cell.setup(imageModel)
        cell.delegate = self
        return cell
    }
}

extension SearchViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        
        if indexPath.row >= images.count - 8, currentPage < maxPage {
            currentPage += 1
            searchImages(searchText: currentQuery, page: currentPage + 1)
        }
    }
}

extension SearchViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let yourWidth = collectionView.bounds.width/4.0
        let yourHeight = yourWidth
        
        return CGSize(width: yourWidth, height: yourHeight)
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

extension SearchViewController: ImageCollectionViewCellDelegate {
    func doubleTapCell(_ cell: ImageCollectionViewCell) {
        guard let index = collectionView.indexPath(for: cell) else {
            return
        }
        self.selectedIndexPath = index
        let vc = ViewModeViewController(images: self.images, selectedIndex: index, rootVC: self)
        RequestService.shared.stopAllTasks()
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension SearchViewController: ZoomingViewController {
    func zoomingImageView(for transition: ZoomTransitioningDelegate) -> UIImageView? {
        guard let indexPath = selectedIndexPath else {
            return nil
        }
        if let cell  = collectionView.cellForItem(at: indexPath) as? ImageCollectionViewCell {
            return cell.imageView
        } else {
            let visibleCell = collectionView.visibleCells
            var visibleIndexes = visibleCell.map { (cell) -> IndexPath in
                return (collectionView.indexPath(for: cell) ?? IndexPath(row: -1, section: -1))
            }
            visibleIndexes = visibleIndexes.filter({$0.row != -1})
            guard let minIndex = visibleIndexes.min(by: {$0.row < $1.row}) else {
                return nil
            }
            guard let maxIndex = visibleIndexes.max(by: {$0.row > $1.row}) else {
                return nil
            }
            
            if indexPath > maxIndex {
                collectionView.scrollToItem(at: indexPath, at: .bottom, animated: false)
                return nil
            } else if indexPath < minIndex {
                collectionView.scrollToItem(at: indexPath, at: .top, animated: false)
                return nil
            }
        }
        return nil
    }
    
    func zoomingBackgroundView(for transiotion: ZoomTransitioningDelegate) -> UIView? {
        return nil
    }
}
