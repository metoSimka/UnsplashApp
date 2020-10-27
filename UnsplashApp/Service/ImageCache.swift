//
//  ImageCache.swift
//  UnsplashApp
//
//  Created by metoSimka on 22.10.2020.
//  Copyright © 2020 metoSimka. All rights reserved.
//

import Foundation
import UIKit

class ImageCache {
    static let shared = ImageCache()
    
    let cache = NSCache<NSString, UIImage>()
    
    let memoryLimit = 1024 * 1024 * 300 // 300 MB
    
    private init() {
        self.cache.totalCostLimit = memoryLimit
    }
}
