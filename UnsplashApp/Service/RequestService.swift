//
//  RequestService.swift
//  UnsplashApp
//
//  Created by metoSimka on 20.10.2020.
//  Copyright © 2020 metoSimka. All rights reserved.
//

import Foundation
import UIKit
class ExampleClass {
    
}

class RequestService {
    // MARK: - Public constants
    
    static let shared = RequestService()
    // MARK: - Public variables
    public var isDownloading = false
    
    // MARK: - IBOutlets
    
    // MARK: - Private constants
    private let defaultStartPageRequestUrl = photosKey + perPageKey + popularKey
    private let defaultSession = URLSession(configuration: .default)
    
    static private let perPageKey = "&per_page=12"
    static private let pageKey = "&page="
    static private let popularKey = "&popuplar"
    static private let photosKey = "photos?"
    static private let searchKey = "search/"
    static private let queryKey = "&query="
    
    // MARK: - Private variables
    private var taskQueue: [RequestTask] = []

    // MARK: - Lifecycle
    
    // MARK: - IBActions
    
    // MARK: - Public methods
    
    public func stopAllTasks() {
        taskQueue.first?.task.cancel()
        taskQueue = []
    }
    
    public func addSearchTask(_ text: String?, currentPage: Int, completion: (([ImageURLs]) -> Void)?) {
        guard let url = with(text, currentPage: currentPage) else {
            return
        }
        getSearchResults(url: url) { (imageModel, error) in
            guard let image = imageModel else {
                DispatchQueue.main.async {
                    completion?([])
                }
                return
            }
            DispatchQueue.main.async {
                completion?(image)
            }
        }
        return
    }
    
    public func getSearchResults(url: URL, completion: @escaping([ImageURLs]?, Error?) -> Void) {
        var urlRequest = URLRequest(url: url)
        urlRequest.setValue("Client-ID \(Constants.accessKey)", forHTTPHeaderField: "Authorization")
        let taskExist = self.taskQueue.contains(where: {$0.urlRequest == urlRequest})
        guard taskExist == false else {
            return
        }
        let dataTask = defaultSession.dataTask(with: urlRequest, completionHandler: { (data, response, error) in
            if let requestTask = self.taskQueue.first(where: {$0.urlRequest == urlRequest}) {
                requestTask.task.cancel()
                guard let index = self.taskQueue.firstIndex(where: {$0.urlRequest == urlRequest}) else {
                    return
                }
                self.taskQueue.remove(at: index)
            }
            guard let data = data else {
                return
            }
            do {
                self.isDownloading = false
                if let popularResult = try? JSONDecoder().decode([ImagePopularResponse].self, from: data) {
                    let images = popularResult.map { (result) -> ImageURLs in
                        return result.urls
                    }
                    completion(images, error)
                } else if let searchResult = try? JSONDecoder().decode(ImageSearchResponse.self, from: data) {
                    let images = searchResult.results.map { (result) -> ImageURLs in
                        return result.urls
                    }
                    completion(images, error)
                } else {
                    print(String(data: data, encoding: .utf8))
                }
            }
        })
        let task = RequestTask(urlRequest: urlRequest, task: dataTask)
        self.taskQueue.append(task)
        task.task.resume()
    }
    
    public func executeTaskFromQueue() {
        guard isDownloading == false else {
            return
        }
        isDownloading = true
        self.taskQueue.first?.task.resume()
    }
    
    @discardableResult func loadImage(urlString: String, useCache: Bool = true, completion: @escaping(UIImage?) -> Void) -> URLSessionDataTask? {
        guard let url = URL(string: urlString) else {
            completion(nil)
            return nil
        }
        guard let nsURL = url.absoluteString as NSString? else {
            completion(nil)
            return nil
        }
        if let imageFromCache = ImageCache.shared.cache.object(forKey: nsURL) {
            completion(imageFromCache)
            return nil
        } else {
            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                do {
                    guard let data = data else {
                        completion(nil)
                        return
                    }
                    guard let image = UIImage(data: data) else {
                        completion(nil)
                        return
                    }
                    if useCache {
                        ImageCache.shared.cache.setObject(image, forKey: nsURL)
                    }
                    DispatchQueue.main.async {
                        completion(image)
                    }
                }
            }
            task.resume()
            return task
        }
    }
    
    // MARK: - Private methods
    private func with(_ searchText: String? = nil, currentPage: Int) -> URL? {
        var searchQuery: String = ""
        if let text = searchText {
            searchQuery = RequestService.searchKey + RequestService.photosKey + RequestService.perPageKey + RequestService.queryKey + text
        } else {
            searchQuery = defaultStartPageRequestUrl
        }
        let pageNumber = "&page=\(currentPage)"
        let url = Constants.baseUrl + searchQuery + pageNumber
        return URL(string: url)
    }
}

// MARK: - Protocol Conformance
