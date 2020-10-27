//
//  SaveImageService.swift
//  UnsplashApp
//
//  Created by metoSimka on 25.10.2020.
//  Copyright © 2020 metoSimka. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class CoreDataManager {

    static let shared = CoreDataManager()
    
    public var fetchedImages: [UIImage] = []
    
    private init() {
        coreDataSetup()
    }
    
    let convertQueue = DispatchQueue(label: "convertQueue", attributes: .concurrent)
    let saveQueue = DispatchQueue(label: "saveQueue", attributes: .concurrent)
    
    var managedContext : NSManagedObjectContext?

    var threadContext: NSManagedObjectContext?
//    public func prefetchImages() {
//        fetchImagesFromCoreData() { images in
//            self.fetchedImages = images
//        }
//    }
    
    public func clearAllCoreData() {
        clearCoreData(entity: "HResolution")
        clearCoreData(entity: "Thumbnail")
    }
    
    public func fetchImagesFromCoreData(completion: @escaping([UIImage]) -> Void) {
        CoreDataManager.shared.loadImages { (imageEntities) in
            guard let thumbEntities = imageEntities else {
                return
            }
            var images: [UIImage] = []
            for thumb in thumbEntities {
                let image: UIImage
                if let fullImageData = thumb.hResolution, let data = fullImageData.imageData {
                    guard let fullImage = UIImage(data: data) else {
                        continue
                    }
                    image = fullImage
                } else if let thumbImageData = thumb.imageData {
                    guard let thumbImage = UIImage(data: thumbImageData) else {
                        continue
                    }
                    image = thumbImage
                } else {
                    continue
                }
                images.append(image)
            }
            completion(images)
        }
    }
    
    public func clearCoreData(entity: String) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        fetchRequest.returnsObjectsAsFaults = false
        do {
            guard let results = try managedContext?.fetch(fetchRequest) else {
                return
            }
            for object in results {
                guard let objectData = object as? NSManagedObject else {continue}
                managedContext?.delete(objectData)
            }
        } catch let error {
            print("Detele all data in \(entity) error :", error)
        }
    }
    
    func coreDataSetup() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        saveQueue.sync {
            self.managedContext = appDelegate.persistentContainer.viewContext
        }
    }
    
    private func isImageUrlContains(imageURls: ImageURLs, in urlList: [String]) -> Bool {
        if urlList.contains(imageURls.thumb) ||
            urlList.contains(imageURls.raw) ||
            urlList.contains(imageURls.full) ||
            urlList.contains(imageURls.small) ||
            urlList.contains(imageURls.regular) {
            return true
        } else {
            return false
        }
    }
    
    func saveImage(thumbnailImage: UIImage, fullimage: UIImage?, imageURLs: ImageURLs) {
        // dispatch with gcd.
        let date: Double = NSDate().timeIntervalSince1970
        convertQueue.async {
            var existingEntityUrls: [String] = []
            self.loadImages { (entities) in
                guard let imageEntities = entities else {
                    return
                }
                for imageEntity in imageEntities {
                    let url = imageEntity.url
                    existingEntityUrls.append(url)
                }
            }
            guard self.isImageUrlContains(imageURls: imageURLs, in: existingEntityUrls) == false else {
                print("image alreadyContains")
                return
            }
            guard let thumbImageData = thumbnailImage.jpegData(compressionQuality: 1) else {
                print("jpg error")
                return
            }
            let regularImageData: Data? = fullimage?.jpegData(compressionQuality: 1)
            let thumbnailUrl = imageURLs.thumb
            self.saveImageData(fullImageData: regularImageData ?? thumbImageData, thumbImageData: thumbImageData, id: date, url: thumbnailUrl)
        }
    }
    
    private func saveImageData(fullImageData: Data, thumbImageData: Data , id: Double, url: String) {
        self.threadContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        threadContext?.persistentStoreCoordinator = managedContext?.persistentStoreCoordinator
        saveQueue.async(flags: .barrier) {
            // create new objects in moc
            guard let moc = self.threadContext else {
                print("error threadContext")
                return
            }
            
            guard let highResolution = NSEntityDescription.insertNewObject(forEntityName: "HResolution", into: moc) as? HResolution else {
                print("moc error")
                return
            }
            guard let thumbnail = NSEntityDescription.insertNewObject(forEntityName: "Thumbnail", into: moc) as? Thumbnail else {
                print("moc error")
                return
            }
            
            //set image data of fullres
            highResolution.imageData = fullImageData
            highResolution.thumbnail = thumbnail
            
            //set image data of thumbnail
            thumbnail.url = url
            thumbnail.imageData = thumbImageData
//            thumbnail.id = id
            thumbnail.hResolution = highResolution
            
            // save the new objects
            do {
                try moc.save()
            } catch {
                print("Failure to save context: \(error)")
            }
            
            // clear the moc
            moc.refreshAllObjects()
        }
    }
    
    public func loadImages(fetched: @escaping(_ images:[Thumbnail]?) -> Void) {
        saveQueue.async {
            guard let moc = self.managedContext else {
                return
            }
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Thumbnail")
            
            do {
                let results = try moc.fetch(fetchRequest)
                let imageData = results as? [Thumbnail]
                DispatchQueue.main.async {
                    fetched(imageData)
                }
            } catch let error as NSError {
                print("Could not fetch \(error), \(error.userInfo)")
                return
            }
        }
    }
}
