//
//  LibraryViewController.swift
//  UnsplashApp
//
//  Created by metoSimka on 26.10.2020.
//  Copyright © 2020 metoSimka. All rights reserved.
//

import UIKit

class LibraryViewController: UIViewController {
    // MARK: - Public constants
    // MARK: - Public variables
    // MARK: - IBOutlets
    // MARK: - Private constants
    // MARK: - Private variables
    
  
    @IBOutlet weak var selectButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var delete: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    private let defaultAnimationTime: TimeInterval = 0.1
    private let disabledAlpha: CGFloat = 0.3
    private let countImagesInRow = 4
    
    internal var doubleTappedIndexPath: IndexPath?
    private var imageModel: [Thumbnail] = []
    private var selectedIndexPaths: [IndexPath] = []
    private var inSelectMode = false
    private let zoomTransition = ZoomTransitioningDelegate()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        CoreDataManager.shared.getPrefetchedImages { (images) in
            self.imageModel = images
        }
        fetchCoreDataImages()
        self.navigationController?.delegate = self
        setupCollectionView()
        setupSelectButton()
    }
    // MARK: - IBActions
    @IBAction func back(_ sender: UIButton) {
        self.navigationController?.delegate = nil
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func selectButtonTouched(_ sender: UIButton) {
        selectButton.isSelected = !selectButton.isSelected
        updateSelectState(selectButton.isSelected)
    }

    @IBAction func saveButtonTouched(_ sender: UIButton) {
        for indexPath in selectedIndexPaths {
            let thumbnailEnitity = imageModel[indexPath.row]
            guard let data = thumbnailEnitity.hResolution?.imageData else {
                continue
            }
            guard let image = UIImage(data: data) else {
                continue
            }
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        }
        self.updateSelectState(false)
        let alert = UIAlertController(title: "Saved!", message: "Images has been saved to your photos.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    @IBAction func deleteButtonTouched(_ sender: UIButton) {
        var imagesForDelete: [Thumbnail] = []
        for indexPath in selectedIndexPaths {
            let enitity = imageModel[indexPath.row]
            imagesForDelete.append(enitity)
        }
        for deletableImage in imagesForDelete {
            self.imageModel.removeAll(where: {$0.url == deletableImage.url})
        }
        collectionView.deleteItems(at: selectedIndexPaths)
        CoreDataManager.shared.deleteImages(thumbnailEntities: imagesForDelete)
        selectedIndexPaths = []
    }
    
    // MARK: - Public methods
    public func fetchCoreDataImages() {
        CoreDataManager.shared.prefetchImages { (result) in
            guard let images = result else {
                return
            }
            self.imageModel = images
            self.collectionView.reloadData()
        }
    }

    // MARK: - Private methods
    private func updateSelectState(_ isSelected: Bool) {
        inSelectMode = isSelected
        selectButton.isSelected = isSelected
        updateSaveButton()
        selectedIndexPaths = []
        if inSelectMode == false {
            self.collectionView.reloadData()
        }
    }
    
    @objc private func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            let alert = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }

    private func setupCollectionView() {
        collectionView.register( UINib(nibName: "LibraryImageCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "LibraryImageCollectionViewCell")
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
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
}

// MARK: - Protocol Conformance
extension LibraryViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageModel.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LibraryImageCollectionViewCell", for: indexPath) as?  LibraryImageCollectionViewCell else {
            return UICollectionViewCell()
        }
        let image = imageModel[indexPath.row]
        guard let imageData = image.imageData else {
            return cell
        }
        let isSelected = selectedIndexPaths.contains(indexPath)
        cell.setup(imageData: imageData, isSelected: isSelected)
        cell.delegate = self
        return cell
    }
}

extension LibraryViewController: UICollectionViewDelegate {

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

extension LibraryViewController: UICollectionViewDelegateFlowLayout {
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

extension LibraryViewController: ImageCellDelegate {
    func doubleTapCell(_ cell: ImageCollectionViewCell) {
        guard inSelectMode == false else {
            return
        }
        guard let index = collectionView.indexPath(for: cell) else {
            return
        }
        self.doubleTappedIndexPath = index
        let detailImageModel = DetailImageModel.initArray(fromThumbnailEntities: imageModel)
        let vc = DetailViewModeViewController(images: detailImageModel, selectedIndex: index, rootVC: self)
        self.navigationController?.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension LibraryViewController: ZoomingViewController {
    func zoomingImageView(for transition: ZoomTransitioningDelegate) -> UIImageView? {
        guard let indexPath = doubleTappedIndexPath else {
            return nil
        }
        if let cell  = collectionView.cellForItem(at: indexPath) as? LibraryImageCollectionViewCell {
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

extension LibraryViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        zoomTransition.operation = operation
        return zoomTransition
    }
}
