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

// MARK: - Protocol Conformance
class CoreDataManager {

    static let shared = CoreDataManager()

    private var fetchedImages: [Thumbnail] = []

    private init() {
        coreDataSetup()
    }
    
    // MARK: - Private constants
    private let convertQueue = DispatchQueue(label: "convertQueue", attributes: .concurrent)
    private let saveQueue = DispatchQueue(label: "saveQueue", attributes: .concurrent)
    
    // MARK: - Private variables
    private var managedContext : NSManagedObjectContext?
    private var threadContext: NSManagedObjectContext?
    
    public func saveImage(thumbnailImage: UIImage, fullimage: UIImage?, imageURLs: ImageURLs) {
        let date: Double = NSDate().timeIntervalSince1970
        convertQueue.async {
            guard let thumbImageData = thumbnailImage.jpegData(compressionQuality: 1) else {
                print("jpg error")
                return
            }
            let regularImageData: Data? = fullimage?.jpegData(compressionQuality: 1)
            let thumbnailUrl = imageURLs.thumb
            self.saveImageData(fullImageData: regularImageData ?? thumbImageData, thumbImageData: thumbImageData, id: date, url: thumbnailUrl)
        }
    }
    
    // MARK: - Public methods
    public func getPrefetchedImages(_ completion: @escaping([Thumbnail])->Void) {
        if fetchedImages.isEmpty {
            prefetchImages() { result in
                DispatchQueue.main.async {
                    self.fetchedImages = result ?? []
                    completion(self.fetchedImages)
                }
            }
        } else {
            completion(self.fetchedImages)
        }
    }
    
    public func deleteImages(thumbnailEntities: [Thumbnail]) {
        for thumbnailEntity in thumbnailEntities {
            if let hResolutionEntity = thumbnailEntity.hResolution {
                managedContext?.delete(hResolutionEntity)
            }
            managedContext?.delete(thumbnailEntity)
        }
        try? managedContext?.save()
    }

    public func prefetchImages(completion: (([Thumbnail]?)->Void)?) {
        CoreDataManager.shared.fetchThumbnailEntities { (result) in
            self.fetchedImages = result ?? []
            completion?(result)
        }
    }

    public func isImageUrlContainsInCoreData(_ imageUrls: ImageURLs, completion: @escaping(Bool) -> Void) {
        var existingEntityUrls: [String] = []
        self.fetchThumbnailEntities { (entities) in
            guard let imageEntities = entities else {
                return
            }
            for imageEntity in imageEntities {
                let url = imageEntity.url
                existingEntityUrls.append(url)
            }
            let isContains = self.isImageUrlContains(imageURls: imageUrls, in: existingEntityUrls)
            completion(isContains)
        }

    }
    
    // MARK: - Private methods
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

    private func saveImageData(fullImageData: Data, thumbImageData: Data , id: Double, url: String) {
        self.threadContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        threadContext?.persistentStoreCoordinator = managedContext?.persistentStoreCoordinator
        saveQueue.async(flags: .barrier) {
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
            
            highResolution.imageData = fullImageData
            highResolution.thumbnail = thumbnail
            
            thumbnail.url = url
            thumbnail.imageData = thumbImageData
            thumbnail.hResolution = highResolution

            do {
                try moc.save()
            } catch {
                print("Failure to save context: \(error)")
            }
            moc.refreshAllObjects()
        }
    }
    
    private func fetchThumbnailEntities(fetched: @escaping(_ images:[Thumbnail]?) -> Void) {
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
    
    private func coreDataSetup() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        saveQueue.sync {
            self.managedContext = appDelegate.persistentContainer.viewContext
        }
    }
}
