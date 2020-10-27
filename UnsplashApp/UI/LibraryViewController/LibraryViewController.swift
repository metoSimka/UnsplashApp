//
//  LibraryViewController.swift
//  UnsplashApp
//
//  Created by metoSimka on 26.10.2020.
//  Copyright © 2020 metoSimka. All rights reserved.
//

import UIKit

class LibraryViewController: UIViewController {

    struct LibraryImage {
        var thumbImage: UIImage
        var fullImage: UIImage
    }
    
    @IBOutlet weak var selectButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var delete: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    private let defaultAnimationTime: TimeInterval = 0.1
    private let disabledAlpha: CGFloat = 0.3
    private let countImagesInRow = 4
    
    private var doubleTappedIndexPath: IndexPath?
    private var images: [LibraryImage] = []
    private var imageModel: [Thumbnail] = []
    private var selectedIndexPaths: [IndexPath] = []
    private var inSelectMode = false
    private let zoomTransition = ZoomTransitioningDelegate()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.delegate = self
        setupCollectionView()
        setupSelectButton()
        
        CoreDataManager.shared.loadImages { (result) in
            self.imageModel = result ?? []
            self.collectionView.reloadData()
            return
            guard let thumbnailEntity = result else {
                return
            }
            var libImages: [LibraryImage] = []
            for entity in thumbnailEntity {
                guard let thumbnailImageData = entity.imageData else {
                    continue
                }
                guard let fullEntity = entity.hResolution else {
                    continue
                }
                guard let fullImageData = fullEntity.imageData else {
                    continue
                }
                guard let thumbnailImage = UIImage(data: thumbnailImageData) else {
                    continue
                }
                guard let fullImage = UIImage(data: fullImageData) else {
                    continue
                }
                let libImage = LibraryImage(thumbImage: thumbnailImage, fullImage: fullImage)
                libImages.append(libImage)
            }
            self.images = libImages
            self.collectionView.reloadData()
        }
    }
    
    @IBAction func back(_ sender: UIButton) {
        self.navigationController?.delegate = nil
        self.navigationController?.popViewController(animated: true)
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
    
    @IBAction func saveButtonTouched(_ sender: UIButton) {
        for indexPath in selectedIndexPaths {
            let image = images[indexPath.row].fullImage
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        }
        let alert = UIAlertController(title: "Saved!", message: "Your altered image has been saved to your photos.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            let alert = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }
    
    @IBAction func deleteButtonTouched(_ sender: UIButton) {
        
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
//        let vc = ViewModeViewController(images: self.images, selectedIndex: index, rootVC: self)
//        RequestService.shared.stopAllTasks()
//        self.navigationController?.pushViewController(vc, animated: true)
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
