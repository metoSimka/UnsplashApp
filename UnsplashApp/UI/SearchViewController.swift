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
    private let requestService = RequestService()
    
    // MARK: - Private variables
    static private let perPage = 12

    private var currentPage = 1
    private var images: [ImageURLs] = []
    private var currentQuery: String?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        requestService.addSearchTask(nil, currentPage: 1) { (imageDatas) in
            self.updateImages(imageDatas)
        }
    }
    
     // MARK: - IBActions
    @IBAction func search(_ sender: UIButton) {
        resetVariables()
        currentQuery = getQueryFromTextField()
        requestService.stopAllTasks()
        searchImages(searchText: currentQuery, page: currentPage)
        self.collectionView.reloadData()
    }
    
    private func resetVariables() {
        self.currentPage = 1
        self.images = []
        ImageCache.shared.cache.removeAllObjects()
    }
    
    // MARK: - Public methods
    
    // MARK: - Private methods
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
        requestService.addSearchTask(currentQuery, currentPage: page) { imageDatas in
            self.updateImages(imageDatas)
            self.requestService.executeTaskFromQueue()
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
