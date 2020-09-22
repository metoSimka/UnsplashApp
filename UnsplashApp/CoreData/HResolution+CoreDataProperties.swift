//
//  HResolution+CoreDataProperties.swift
//  UnsplashApp
//
//  Created by metoSimka on 22.09.2020.
//  Copyright © 2020 metoSimka. All rights reserved.
//
//

import Foundation
import CoreData


extension HResolution {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<HResolution> {
        return NSFetchRequest<HResolution>(entityName: "HResolution")
    }

    @NSManaged public var imageData: Data?
    @NSManaged public var thumbnail: Thumbnail?

}
