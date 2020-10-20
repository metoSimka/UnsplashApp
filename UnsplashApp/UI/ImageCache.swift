//
//  ImageCache.swift
//  UnsplashApp
//
//  Created by metoSimka on 20.10.2020.
//  Copyright © 2020 metoSimka. All rights reserved.
//

import Foundation
import UIKit

class ImageCache {
    
    static let shared = ImageCache()

    private var cache: [URL: UIImage] = [:]
    
    fileprivate init() {
    }

    public func saveToCache(url: URL, image: UIImage) {
        self.cache[url] = image
    }
    
    public func getImage(url: URL) -> UIImage? {
        let image = cache[url]
        return image
    }
}
