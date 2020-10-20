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
    private var imageModels: [ImageModel] = []
    private let placeholderImage = UIImage(named: "placeholder")
    
    var activeDownloads: [URL: DownloadRequest] = [:]
    
    lazy var downloadsSession: URLSession = {
      let configuration = URLSessionConfiguration.default
      
      return URLSession(configuration: configuration,
                        delegate: self,
                        delegateQueue: nil)
    }()
    
    let defaultSession = URLSession(configuration: .default)
    var dataTask: URLSessionDataTask?
    
    private func getSearchResults(url: URL,searchText: String, completion: @escaping(Int)->Void) {
        dataTask?.cancel()
        var urlRequest = URLRequest(url: url)
        urlRequest.setValue("Client-ID \(Constants.accessKey)", forHTTPHeaderField: "Authorization")
        dataTask = defaultSession.dataTask(with: urlRequest, completionHandler: { (data, response, error) in
            self.dataTask = nil
            if let err = error {
                print(err)
                return
            }
            guard let data = data else {
                return
            }
            do {
                let image = try? JSONDecoder().decode([ImageModel].self, from: data)
                completion(self?.tracks, self?.errorMessage ?? "")
            }
        })
    }
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        guard let url = with(defaultStartPageRequest, currentPage: 1) else {
            return
        }
        request(url) { imageModel in
            guard let imageModel = imageModel else {
                return
            }
            DispatchQueue.main.async {
                self.imageModels.append(contentsOf: imageModel)
                self.collectionView.reloadData()
            }
        }

        // Do any additional setup after loading the view.
    }
    
    private func searchImage(_ text: String) {
        
    }

    func with(_ string: String, currentPage: Int) -> URL? {
        return URL(string: "\(Constants.baseUrl)\(string);page=\(currentPage)")
    }
    
    private func setupCollectionView() {
        collectionView.register( UINib(nibName: "ImageCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ImageCollectionViewCell")
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    private func request(_ url: URL, completion: @escaping([ImageModel]?) -> Void ) {
        let concurrentQueue = DispatchQueue(label: "request", attributes: .concurrent)
//        let downloadableItems = Array(repeating: ImageModel(), count: SearchViewController.perPage)
//        self.imageModels.append(contentsOf: downloadableItems)
        concurrentQueue.sync {
            var urlRequest = URLRequest(url: url)
            urlRequest.setValue("Client-ID \(Constants.accessKey)", forHTTPHeaderField: "Authorization")
            URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
                guard let data = data else {
                    return
                }
                do {
                    let image = try? JSONDecoder().decode([ImageModel].self, from: data)
                    completion(image)
                }
            }.resume()
        }
    }

    private func updateImageModel(newImageList: [ImageModel]) {
        var filteredImages: [ImageModel] = []
        let currentCount = imageModels.count
        for image in newImageList {
            let contains = imageModels.contains(where: { (item) -> Bool in
                if item == image {
                    return true
                } else {
                    return false
                }
            })
            guard contains == false else {
                continue
            }
            filteredImages.append(image)
        }
        imageModels.append(contentsOf: filteredImages)
        collectionView.reloadData()
    }
}

extension SearchViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCollectionViewCell", for: indexPath) as?  ImageCollectionViewCell else {
            return UICollectionViewCell()
        }
        let imageModel = imageModels[indexPath.row]
        cell.setUrls(imageModel)
        return cell
    }
}

extension SearchViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                 willDisplay cell: UICollectionViewCell,
                   forItemAt indexPath: IndexPath) {
        return
        if indexPath.row >= imageModels.count - 8 {
            let curPage = imageModels.count/SearchViewController.perPage
            guard currentPage - 1 < curPage else {
                return
            }
            currentPage = currentPage + 1
            print("request for", currentPage)
            guard let url = with(defaultStartPageRequest, currentPage: currentPage) else {
                return
            }
            request(url) { (images) in
                guard let images = images else {
                    return
                }
                DispatchQueue.main.async {
                    self.updateImageModel(newImageList: images)
                }
            }
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
    
extension SearchViewController: URLSessionDownloadDelegate {
  func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask,
                  didFinishDownloadingTo location: URL) {
    print("Finished downloading to \(location).")
  }
}
