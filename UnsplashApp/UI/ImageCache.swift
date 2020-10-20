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

extension UIImage {

    func decodedImage() -> UIImage {
        guard let cgImage = cgImage else { return self }
        let size = CGSize(width: cgImage.width, height: cgImage.height)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: nil, width: Int(size.width), height: Int(size.height), bitsPerComponent: 8, bytesPerRow: cgImage.bytesPerRow, space: colorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
        context?.draw(cgImage, in: CGRect(origin: .zero, size: size))
        guard let decodedImage = context?.makeImage() else { return self }
        return UIImage(cgImage: decodedImage)
    }
}
