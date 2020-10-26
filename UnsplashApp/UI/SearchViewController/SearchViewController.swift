//
//  SearchViewController.swift
//  UnsplashApp
//
//  Created by metoSimka on 19.10.2020.
//  Copyright © 2020 metoSimka. All rights reserved.
//

import UIKit
import CoreData

class SearchViewController: UIViewController {
    
    // MARK: - Public constants
    
    // MARK: - Public variables

    // MARK: - IBOutlets
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var selectButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    // MARK: - Private constants
    private let maxPage = 100
    static private let perPage = 12
    private let disabledAlpha: CGFloat = 0.3
    private let defaultAnimationTime: TimeInterval = 0.2
    private let countImagesInRow = 4
    
    // MARK: - Private variables

    private var currentPage = 1
    private var images: [ImageURLs] = []
    private var currentQuery: String?
    
    private var doubleTappedIndexPath: IndexPath?
    
    private var inSelectMode = false
    private var selectedIndexPaths: [IndexPath] = []
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        SaveImageService.shared.clearAllCoreData()
        setupSelectButton()
        setupCollectionView()
        RequestService.shared.addSearchTask(nil, currentPage: 1) { (imageDatas) in
            self.updateImages(imageDatas)
        }
        updateSaveButton()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        SaveImageService.shared.loadImages { (fetched) in
            var images: [UIImage] = []
            guard let thumbnailList = fetched else {
                return
            }
            for thumbnail in thumbnailList {
                guard let data = thumbnail.imageData else {
                    return
                }
                guard let image = UIImage(data: data) else {
                    return
                }
                images.append(image)
            }
            print(images.count)
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
    
    @IBAction func selectButtonTouched(_ sender: UIButton) {
        selectButton.isSelected = !selectButton.isSelected
        inSelectMode = selectButton.isSelected
        updateSaveButton()
        selectedIndexPaths = []
        if inSelectMode == false {
            self.collectionView.reloadData()
        }
    }
    
    @IBAction func saveSelectedImages(_ sender: UIButton) {

        for indexPath in selectedIndexPaths {
            let urls = images[indexPath.row]
            RequestService.shared.loadImage(urlString: urls.thumb) { (imageThumb) in
                guard let imageThumbnail = imageThumb else {
                    return
                }
                RequestService.shared.loadImage(urlString: urls.regular) { (imageReg) in
                    guard let imageRegular = imageReg else {
                        return
                    }
                    SaveImageService.shared.prepareImageForSaving(thumbImage: imageThumbnail, thumbUrl: urls.thumb, highResolutionImage: imageRegular)
                    DispatchQueue.main.async {
                        print("Image saved")
                    }
                }
            }
        }
    }
    
    // MARK: - Public methods
    public func syncSelectedIndexPath(indexPath: IndexPath) {
        self.doubleTappedIndexPath = indexPath
    }

    // MARK: - Private methods
    private func setupSelectButton() {
        selectButton.setTitle("Cancel", for: .selected)
        selectButton.setTitle("Select", for: .normal)
        selectButton.isSelected = false
    }

    private func updateSaveButton() {
        UIView.animate(withDuration: defaultAnimationTime) {
            if self.inSelectMode {
                self.saveButton.alpha = 1
                self.saveButton.isUserInteractionEnabled = true
            } else {
                self.saveButton.alpha = self.disabledAlpha
                self.saveButton.isUserInteractionEnabled = false
            }
        }
    }
    
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
        let isSelected = selectedIndexPaths.contains(indexPath)
        cell.setup(imageModel, isSelected: isSelected)
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard inSelectMode else {
            return
        }
        if selectedIndexPaths.contains(indexPath) {
            selectedIndexPaths.removeAll(where: {$0 == indexPath})
        } else {
            selectedIndexPaths.append(indexPath)
        }
        collectionView.reloadItems(at: [indexPath])
    }
}

extension SearchViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let yourWidth = collectionView.bounds.width/CGFloat(countImagesInRow)
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
        guard inSelectMode == false else {
            return
        }
        guard let index = collectionView.indexPath(for: cell) else {
            return
        }
        self.doubleTappedIndexPath = index
        let vc = ViewModeViewController(images: self.images, selectedIndex: index, rootVC: self)
        RequestService.shared.stopAllTasks()
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension SearchViewController: ZoomingViewController {
    func zoomingImageView(for transition: ZoomTransitioningDelegate) -> UIImageView? {
        guard let indexPath = doubleTappedIndexPath else {
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
