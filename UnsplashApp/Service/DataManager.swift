//
//  DataManager.swift
//  UnsplashApp
//
//  Created by metoSimka on 23.09.2020.
//  Copyright © 2020 metoSimka. All rights reserved.
//

import Foundation
import CoreData

class DataManager {
    
    private var context = AppDelegate().persistentContainer.viewContext
    
    func test() {
        var image = Thumbnail(context: context)
        
    }
    
    public func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                context.rollback()
                let nserror = error as NSError
                fatalError(nserror.localizedDescription)
            }
        }
    }
    
    public func deleteObject(object: NSManagedObject) {
        context.delete(object)
    }
    
    public func fetchObjects() {
        AppDelegate().persistentContainer.performBackgroundTask { (context) in
            
        }
        let fetchRequest: NSFetchRequest<Thumbnail> = Thumbnail.fetchRequest()
        let objects = try? context.fetch(fetchRequest)
    }
}
