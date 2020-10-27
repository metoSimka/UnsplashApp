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
    @IBOutlet weak var libraryPageButton: UIButton!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var selectButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    // MARK: - Private constants
    private let maxPage = 100
    static private let perPage = 12
    private let disabledAlpha: CGFloat = 0.3
    private let defaultAnimationTime: TimeInterval = 0.1
    private let countImagesInRow = 4
    private let zoomTransition = ZoomTransitioningDelegate()

    // MARK: - Private variables

    private var currentPage = 1
    private var images: [ImageURLs] = []
    private var currentQuery: String?
    
    internal var doubleTappedIndexPath: IndexPath?
    
    private var inSelectMode = false
    private var selectedIndexPaths: [IndexPath] = []
    
    private var saveProcessingView = SaveProcessingView()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideSavingSpinner()
        textField.delegate = self
        setupSelectButton()
        setupCollectionView()
        RequestService.shared.addSearchTask(nil, currentPage: 1) { (imageDatas) in
            self.updateImages(imageDatas)
        }
        updateSaveButton()
        saveProcessingView.addSelf(to: self.view)
        saveProcessingView.contentView?.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
     // MARK: - IBActions
    @IBAction func search(_ sender: UIButton) {
        resetVariables()
        currentQuery = getQueryFromTextField()
        RequestService.shared.stopAllTasks()
        searchImages(searchText: currentQuery, page: currentPage)
        self.collectionView.reloadData()
        textField.resignFirstResponder()
    }
    
    @IBAction func selectButtonTouched(_ sender: UIButton) {
        selectButton.isSelected = !selectButton.isSelected
        switchSelectMode(bool: selectButton.isSelected)
    }
    
    private func switchSelectMode(bool: Bool) {
        inSelectMode = bool
        updateSaveButton()
        selectedIndexPaths = []
        if inSelectMode == false {
            self.collectionView.reloadData()
        }
    }

    @IBAction func libraryPageTouched(_ sender: UIButton) {
        showLibrary()
    }
    
    @IBAction func saveSelectedImages(_ sender: UIButton) {
        showPopupQualityVC()
    }
    
    // MARK: - Public methods

    // MARK: - Private methods
    private func setupSelectButton() {
        selectButton.setTitle("Cancel", for: .selected)
        selectButton.setTitle("Select", for: .normal)
        selectButton.isSelected = false
    }

    private func updateSaveButton() {
        UIView.animate(withDuration: defaultAnimationTime) {
            if self.inSelectMode, self.selectedIndexPaths.count > 0 {
                self.saveButton.alpha = 1
                self.saveButton.isUserInteractionEnabled = true
            } else {
                self.saveButton.alpha = self.disabledAlpha
                self.saveButton.isUserInteractionEnabled = false
            }
        }
    }
  
    private func updateSaveProgress(currentSaveCount: Int, total: Int, errorCount: Int) {
        if currentSaveCount >= total {
            self.hideSavingSpinner()
            self.switchSelectMode(bool: false)
            self.selectButton.isSelected = false
            CoreDataManager.shared.prefetchImages(completion: nil)
            saveProcessingView.updateLabel(text: "Saving")
            if errorCount > 0 {
                let alert = UIAlertController(title: "Warning", message: "Failed to download and save \(errorCount) images. Total saved: \(total - errorCount)", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
            }
        }
        saveProcessingView.updateLabel(text: "Saving \(currentSaveCount)/\(total)")
    }

    private func showPopupQualityVC() {
        let vc = PopupSaveImageViewController()
        vc.delegate = self
        vc.navigationController?.delegate = nil
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .coverVertical
        self.present(vc, animated: true)
    }
    
    private func showSavingSpinner() {
        self.view.isUserInteractionEnabled = false
        self.saveProcessingView.contentView?.isHidden = false
        
    }
    
    private func hideSavingSpinner() {
        self.view.isUserInteractionEnabled = true
        self.saveProcessingView.contentView?.isHidden = true
    }

    private func showLibrary() {
        let vc = LibraryViewController(nibName: "LibraryViewController", bundle: nil)
        vc.modalPresentationStyle = .fullScreen
        self.navigationController?.delegate = nil
        self.navigationController?.pushViewController(vc, animated: true)
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
        collectionView.register( UINib(nibName: "SearchImageCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "SearchImageCollectionViewCell")
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
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SearchImageCollectionViewCell", for: indexPath) as?  SearchImageCollectionViewCell else {
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
        updateSaveButton()
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

extension SearchViewController: ImageCellDelegate {
    func doubleTapCell(_ cell: ImageCollectionViewCell) {
        guard inSelectMode == false else {
            return
        }
        guard let index = collectionView.indexPath(for: cell) else {
            return
        }
        self.doubleTappedIndexPath = index
        let detailImageModel = DetailImageModel.initArray(fromURLs: self.images)
        let vc = DetailViewModeViewController(images: detailImageModel, selectedIndex: index, rootVC: self)
        RequestService.shared.stopAllTasks()
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension SearchViewController: ZoomingViewController {
    func zoomingImageView(for transition: ZoomTransitioningDelegate) -> UIImageView? {
        guard let indexPath = doubleTappedIndexPath else {
            return nil
        }
        if let cell  = collectionView.cellForItem(at: indexPath) as? SearchImageCollectionViewCell {
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

extension SearchViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension SearchViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        zoomTransition.operation = operation
        return zoomTransition
    }
}

extension SearchViewController: PopupSaveImageViewControllerDelegate {
    func PopupSaveImageViewControllerClosed() {
        self.navigationController?.delegate = self
    }
    
    func saveWithQuality(quality: Quality) {
        showSavingSpinner()
        var count = 0
        var finishedWithError: Int = 0
        self.updateSaveProgress(currentSaveCount: count, total: self.selectedIndexPaths.count, errorCount: finishedWithError)
        for indexPath in self.selectedIndexPaths {
            let urls = self.images[indexPath.row]
            let ulr = urls.getUrl(quality: quality)
            CoreDataManager.shared.isImageUrlContainsInCoreData(urls) { isContains in
                if isContains {
                    DispatchQueue.main.async {
                        count += 1
                        self.updateSaveProgress(currentSaveCount: count, total: self.selectedIndexPaths.count, errorCount: finishedWithError)
                    }
                    return
                }
                RequestService.shared.loadImage(urlString: urls.thumb) { (thumbnailResult) in
                    guard let thumbImage = thumbnailResult else {
                        DispatchQueue.main.async {
                            finishedWithError += 1
                            count += 1
                            self.updateSaveProgress(currentSaveCount: count, total: self.selectedIndexPaths.count, errorCount: finishedWithError)
                        }
                        return
                    }
                    RequestService.shared.loadImage(urlString: ulr, useCache: false) { (qualityResult) in
                        guard let qualityImage = qualityResult else {
                            DispatchQueue.main.async {
                                finishedWithError += 1
                                count += 1
                                self.updateSaveProgress(currentSaveCount: count, total: self.selectedIndexPaths.count, errorCount: finishedWithError)
                            }
                            return
                        }
                        CoreDataManager.shared.saveImage(thumbnailImage: thumbImage, fullimage: qualityImage, imageURLs: urls)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                            count += 1
                            self.updateSaveProgress(currentSaveCount: count, total: self.selectedIndexPaths.count, errorCount: finishedWithError)
                        })
                    }
                }
            }
        }
    }
}
