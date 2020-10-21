//
//  SimpleImageCache.swift
//  UnsplashApp
//
//  Created by metoSimka on 20.10.2020.
//  Copyright © 2020 metoSimka. All rights reserved.
//

import Foundation
import UIKit

class SimpleImageCache {
    
    class ImageCacheModel: Equatable {
        var image: UIImage
        var priority: Int = 100
        
        init(image: UIImage) {
            self.image = image
        }
        static func == (lhs: SimpleImageCache.ImageCacheModel, rhs: SimpleImageCache.ImageCacheModel) -> Bool {
            if lhs.image == rhs.image {
                return true
            } else {
                return false
            }
        }
    }
    
    static let shared = SimpleImageCache()

    private var cache: [URL: ImageCacheModel] = [:]
    private var maxCount = 1200
    
    private var requestCounter = 0
    
    fileprivate init() {
    }
    
    public func setMaxCountItems(_ count: Int) {
        self.maxCount = count
    }
    
    private func checkPriorities() {
        requestCounter += 1
        if requestCounter > 50 {
            requestCounter = 0
            self.cache.keys.forEach {self.cache[$0]?.priority -= 1}
        }
    }
    
    public func getImage(url: URL) -> UIImage? {
        checkPriorities()
        let imageModel = self.cache[url]
        imageModel?.priority += 1
        return imageModel?.image
    }
    
    public func saveToCache(url: URL, image: UIImage) {
        let cacheItem = isItemInCache(url: url, image: image)
        if let item = cacheItem {
            item.priority += 1
            return
        }
        if cache.count >= maxCount {
            guard let lowPriorityCacheItem = cache.min(by: {$0.value.priority < $1.value.priority}) else {
                return
            }
            self.cache[lowPriorityCacheItem.key] = nil
        }
        let imageModel = ImageCacheModel(image: image)
        self.cache[url] = imageModel
    }
    
    private func isItemInCache(url: URL, image: UIImage) -> ImageCacheModel? {
        if let imageFromCache = self.cache[url],
           image == imageFromCache.image {
            return imageFromCache
        }
        return nil
    }
}
