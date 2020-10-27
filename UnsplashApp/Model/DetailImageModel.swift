//
//  DetailImageModel.swift
//  UnsplashApp
//
//  Created by metoSimka on 27.10.2020.
//  Copyright © 2020 metoSimka. All rights reserved.
//

import Foundation
import UIKit

struct DetailImageModel {
    var imageURLs: ImageURLs?
    var thumbImage: UIImage?
    var qualityImage: UIImage?
    
    static func initArray(fromURLs urls: [ImageURLs]) -> [DetailImageModel] {
        var detailImageArray: [DetailImageModel] = []
        for url in urls {
            let detailImage = DetailImageModel(imageURLs: url, thumbImage: nil, qualityImage: nil)
            detailImageArray.append(detailImage)
        }
        return detailImageArray
    }
    
    static func initArray(fromThumbnailEntities entities: [Thumbnail]) -> [DetailImageModel] {
        var detailImageArray: [DetailImageModel] = []
        for entity in entities {
            var thumbImage: UIImage?
            var qualityImage: UIImage?
            if let thumbImageData = entity.imageData {
                thumbImage = UIImage(data: thumbImageData)
            }
            if let qualityImageData = entity.hResolution?.imageData {
                qualityImage = UIImage(data: qualityImageData)
            }
            
            let detailImage = DetailImageModel(imageURLs: nil, thumbImage: thumbImage, qualityImage: qualityImage)
            detailImageArray.append(detailImage)
        }
        return detailImageArray
    }
}
