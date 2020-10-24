//
//  RequestTask.swift
//  UnsplashApp
//
//  Created by metoSimka on 23.10.2020.
//  Copyright © 2020 metoSimka. All rights reserved.
//

import Foundation

class RequestTask {
    var urlRequest: URLRequest
    var task: URLSessionDataTask
    init(urlRequest: URLRequest, task: URLSessionDataTask) {
        self.urlRequest = urlRequest
        self.task = task
    }
}
