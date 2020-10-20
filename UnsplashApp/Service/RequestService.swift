//
//  RequestService.swift
//  UnsplashApp
//
//  Created by metoSimka on 20.10.2020.
//  Copyright © 2020 metoSimka. All rights reserved.
//

import Foundation
import UIKit

class RequestService {
    
    public var isDownloading = false
    static let shared = RequestService()
    
    private init() {
    }
    
    static private let perPage = 12
    
    private let defaultStartPageRequest = "photos?per_page=\(perPage);popular"
    
    let defaultSession = URLSession(configuration: .default)
    
    private var taskQueue: [RequestTask] = []
    
    public func addSearchTask(_ text: String, currentPage: Int, completion: (([ImageData]) -> Void)?) {
        guard let url = with(defaultStartPageRequest, currentPage: currentPage) else {
            return
        }
        getSearchResults(url: url, searchText: text) { (imageModel, error) in
            guard let image = imageModel else {
                return
            }
            completion?(image)
        }
        return
    }
    
    public func with(_ string: String, currentPage: Int) -> URL? {
        return URL(string: "\(Constants.baseUrl)\(string);page=\(currentPage)")
    }
    
    public func getSearchResults(url: URL, searchText: String, completion: @escaping([ImageData]?, Error?)->Void) {
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
                let image = try? JSONDecoder().decode([ImageData].self, from: data)
                completion(image, error)
            }
        })
        let task = RequestTask(urlRequest: urlRequest, task: dataTask)
        self.taskQueue.append(task)
    }
    
    public func executeTaskFromQueue() {
        guard isDownloading == false else {
            return
        }
        isDownloading = true
        print("exeute task")
        self.taskQueue.first?.task.resume()
    }
    
    
    public func downloadSingleImage(_ url: URL, completion: @escaping(UIImage?) -> Void) {
        loadImage(url: url) { image in
            completion(image)
        }
    }
    
    @discardableResult func loadImage(url: URL, completion: @escaping(UIImage?) -> Void) -> URLSessionDataTask? {
//        if let imageFromCache = imageCache.object(forKey: url.absoluteString as AnyObject) as? UIImage {
//            completion(imageFromCache)
//            return nil
//        }
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            do {
                guard let data = data else {
                    return
                }
                guard let image = UIImage(data: data) else {
                    return
                }
//                self.imageCache.setObject(image, forKey: url.absoluteString as AnyObject)
                DispatchQueue.main.async {
                    completion(image)
                }
            }
        }
        task.resume()
        return task
    }

}

class RequestTask {
    var urlRequest: URLRequest
    var task: URLSessionDataTask
    init(urlRequest: URLRequest, task: URLSessionDataTask) {
        self.urlRequest = urlRequest
        self.task = task
    }
}

