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
    
    private let memoryLimit = 1024 * 1024 * 300
    
    private init() {
        self.cache.totalCostLimit = memoryLimit
    }
}
