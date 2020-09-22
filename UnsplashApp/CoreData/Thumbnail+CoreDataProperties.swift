//
//  Thumbnail+CoreDataProperties.swift
//  UnsplashApp
//
//  Created by metoSimka on 22.09.2020.
//  Copyright © 2020 metoSimka. All rights reserved.
//
//

import Foundation
import CoreData


extension Thumbnail {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Thumbnail> {
        return NSFetchRequest<Thumbnail>(entityName: "Thumbnail")
    }

    @NSManaged public var id: Double
    @NSManaged public var imageData: Data?
    @NSManaged public var hResolution: HResolution?

}
