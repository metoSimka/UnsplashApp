//
//  SearchViewController.swift
//  UnsplashApp
//
//  Created by metoSimka on 19.10.2020.
//  Copyright © 2020 metoSimka. All rights reserved.
//

import UIKit


class SearchViewController: UIViewController {
    static private let perPage = 12

    private let defaultStartPageRequest = "photos?per_page=\(perPage);popular"
    private var currentPage = 1
    
    private var images: [UnsplashImage] = []
    
    private let placeholderImage = UIImage(named: "placeholder")

    private var expectedDownloadedImageCount: Int = 0
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        RequestService.shared.addSearchTask("", currentPage: 1) { (imageDatas) in
            self.parseImageData(imageDatas: imageDatas)
        }
    }
    
    private func parseImageData(imageDatas: [ImageData]) {
        for imageData in imageDatas {
            let imageModel = UnsplashImage()
            guard let thumbUrl = URL(string: imageData.urls.thumb) else {
                return
            }
            guard let fullUrl = URL(string: imageData.urls.full) else {
                return
            }
            imageModel.highUrl = fullUrl
            imageModel.lowUrl = thumbUrl
            DispatchQueue.main.async {
                self.insertNewUnsplashImage(image: imageModel)
            }
            RequestService.shared.downloadSingleImage(thumbUrl) { image in
                guard let thumbImage = image else {
                    return
                }
                DispatchQueue.main.async {
                    self.updateImageModel(url: thumbUrl, image: thumbImage)
                }
            }
        }
    }
    
    private func updateImageModel(url: URL, image: UIImage) {
        guard let imageModel = images.last(where: { (item) -> Bool in
            if item.lowUrl == url {
                return true
            } else {
                return false
            }
        }) else {
            return
        }
        guard let index: Int = images.firstIndex(of: imageModel) else {
            return
        }
        imageModel.lowImage = image
        self.collectionView.reloadItems(at: [IndexPath(row: index, section: 0)])
    }
    
    private func insertNewUnsplashImage(image: UnsplashImage) {
        guard images.contains(image) == false else {
            return
        }
        images.append(image)
        self.collectionView.insertItems(at: [IndexPath(row: images.count - 1, section: 0)])
    }

    private func setupCollectionView() {
        collectionView.register( UINib(nibName: "ImageCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ImageCollectionViewCell")
        collectionView.dataSource = self
        collectionView.delegate = self
    }
}

extension SearchViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCollectionViewCell", for: indexPath) as?  ImageCollectionViewCell else {
            return UICollectionViewCell()
        }
        guard indexPath.row > 0 else {
            return cell
        }
        let image = images[indexPath.row]

        cell.setImage(image.lowImage)
        return cell
    }
}

extension SearchViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        if indexPath.row >= images.count - 8 {
            currentPage = currentPage + 1
            print("request for", currentPage)
            
            let count = RequestService.shared.addSearchTask("", currentPage: currentPage) { imageDatas in
                self.expectedDownloadedImageCount -= imageDatas.count
                self.parseImageData(imageDatas: imageDatas)
                RequestService.shared.executeTaskFromQueue()
            }
            expectedDownloadedImageCount += count
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

class DownloadRequest {
  var isDownloading = false
  var progress: Float = 0
  var resumeData: Data?
  var task: URLSessionDownloadTask?
  var imageULR: URL
  
  init(imageULR: URL) {
    self.imageULR = imageULR
  }
}

class ImageLoadManager {
    static let manager = ImageLoadManager()
    var cachedImages = [String: UIImage]()
}
