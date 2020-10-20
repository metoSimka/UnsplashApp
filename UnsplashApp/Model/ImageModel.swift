//
//  ImageModel.swift
//  UnsplashApp
//
//  Created by metoSimka on 19.10.2020.
//  Copyright © 2020 metoSimka. All rights reserved.
//

import Foundation

struct ImageModel: Decodable {
    let id: String
    let width: Int
    let height: Int
    let color: String
    let urls: ImageURLs
}

extension ImageModel: Equatable {
    static func == (lhs: ImageModel, rhs: ImageModel) -> Bool {
        if lhs.id == rhs.id,
           lhs.urls == rhs.urls {
            return true
        } else {
            return false
        }
    }
}
