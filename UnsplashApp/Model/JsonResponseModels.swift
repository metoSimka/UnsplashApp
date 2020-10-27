//
//  ImageModel.swift
//  UnsplashApp
//
//  Created by metoSimka on 19.10.2020.
//  Copyright © 2020 metoSimka. All rights reserved.
//

import Foundation
import UIKit

struct ResultsStruct: Decodable {
    let urls: ImageURLs
}

struct ImageSearchResponse: Decodable {
    let total: Int
    let results: [ResultsStruct]
}

struct ImagePopularResponse: Decodable {
    let urls: ImageURLs
}

enum Quality: Int {
    case thumbnail = 0
    case small = 1
    case regular = 2
    case full = 3
    case raw = 4
}

struct ImageURLs: Decodable, Equatable {
    let raw: String
    let full: String
    let regular: String
    let small: String
    let thumb: String
    
    func getUrl(quality: Quality) -> String {
        switch quality {
        case .thumbnail:
            return self.thumb
        case .small:
            return self.small
        case .regular:
            return self.regular
        case .full:
            return self.full
        case .raw:
            return self.raw
        }
    }
}

