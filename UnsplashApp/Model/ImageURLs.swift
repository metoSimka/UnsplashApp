//
//  ImageURLs.swift
//  UnsplashApp
//
//  Created by metoSimka on 19.10.2020.
//  Copyright © 2020 metoSimka. All rights reserved.
//

import Foundation

struct ImageURLs: Decodable, Equatable {
    let raw: String
    let full: String
    let regular: String
    let small: String
    let thumb: String
    let keyNotExist: String?
}
