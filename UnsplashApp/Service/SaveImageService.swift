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

class SaveImageService {
    
    static let shared = SaveImageService()
    
    private init() {
        coreDataSetup()
    }
    
    let covertQueue = DispatchQueue(label: "convertQueue", attributes: .concurrent)
    let saveQueue = DispatchQueue(label: "saveQueue", attributes: .concurrent)
    
    var managedContext : NSManagedObjectContext?
    
    
    public func clearAllCoreData() {
        clearCoreData(entity: "HResolution")
        clearCoreData(entity: "Thumbnail")
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
    
    func prepareImageForSaving(thumbImage: UIImage, thumbUrl: String, highResolutionImage: UIImage) {
        // dispatch with gcd.
        covertQueue.async {
            // create NSData from UIImage
            guard let thumbImageData = thumbImage.jpegData(compressionQuality: 1) else {
                // handle failed conversion
                print("jpg error")
                return
            }
            guard let normalImageData = highResolutionImage.jpegData(compressionQuality: 1) else {
                // handle failed conversion
                print("jpg error")
                return
            }
            // send to save function
            self.saveImage(normalImageData: normalImageData, thumbnailData: thumbImageData, thumbId: thumbUrl)
            
        }
    }
    
    func saveImage(normalImageData: Data, thumbnailData: Data, thumbId: String) {
        saveQueue.async(flags: .barrier) {
            // create new objects in moc
            guard let moc = self.managedContext else {
                return
            }
            
            guard let highResolution = NSEntityDescription.insertNewObject(forEntityName: "HResolution", into: moc) as? HResolution,
                  let thumbnail = NSEntityDescription.insertNewObject(forEntityName: "Thumbnail", into: moc) as? Thumbnail else {
                // handle failed new object in moc
                print("moc error")
                return
            }
            
            //set image data of fullres
            highResolution.imageData = normalImageData
            highResolution.thumbnail = thumbnail
            
            //set image data of thumbnail
            thumbnail.imageData = thumbnailData
            thumbnail.id = ""
            thumbnail.hResolution = highResolution
            
            // save the new objects
            do {
                try moc.save()
            } catch {
                fatalError("Failure to save context: \(error)")
            }
            
            // clear the moc
            moc.refreshAllObjects()
        }
    }
    
    func loadImages(fetched: @escaping(_ images:[Thumbnail]?) -> Void) {
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
