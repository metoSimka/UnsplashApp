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
    static private let perPage = 12
    
    private let defaultStartPageRequest = "photos?per_page=\(perPage);popular"
    private let placeholderImage = UIImage(named: "placeholder")

    let defaultSession = URLSession(configuration: .default)
    
    private var taskQueue: [RequestTask] = []
    
    private func getSearchResults(url: URL, searchText: String, completion: @escaping([ImageModel]?, Error?)->Void) {
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
                let image = try? JSONDecoder().decode([ImageModel].self, from: data)
                completion(image, error)
            }
        })
        let task = RequestTask(urlRequest: urlRequest, task: dataTask)
        self.taskQueue.append(task)
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
