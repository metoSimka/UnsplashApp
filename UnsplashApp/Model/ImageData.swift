//
//  ImageModel.swift
//  UnsplashApp
//
//  Created by metoSimka on 19.10.2020.
//  Copyright © 2020 metoSimka. All rights reserved.
//

import Foundation
import UIKit

struct ImageData: Decodable {
    let id: String
    let width: Int
    let height: Int
    let color: String
    let urls: ImageURLs
}

class UnsplashImage: Equatable {
    static func == (lhs: UnsplashImage, rhs: UnsplashImage) -> Bool {
        if lhs.lowUrl == rhs.lowUrl,
           rhs.highUrl == rhs.highUrl {
            return true
        } else {
            return false
        }
    }
    
    var lowUrl: URL?
    var highUrl: URL?
    
    var lowImage: UIImage?
    var highImage: UIImage?
}

extension ImageData: Equatable {
    static func == (lhs: ImageData, rhs: ImageData) -> Bool {
        if lhs.id == rhs.id,
           lhs.urls == rhs.urls {
            return true
        } else {
            return false
        }
    }
}
