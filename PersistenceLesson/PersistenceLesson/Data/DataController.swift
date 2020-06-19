//
//  DataController.swift
//  PersistenceLesson
//
//  Created by yeuchi on 6/19/20.
//  Copyright © 2020 yeuchi. All rights reserved.
//

import Foundation
import CoreData

class DataController {
     let managedObjectContext: NSManagedObjectContext
        
        init(moc: NSManagedObjectContext) {
            self.managedObjectContext = moc
        }
        
        /*
         * Create Core Data stack in this method
         */
        convenience init?() {
            
            // xc..model files are compiled into momd files
            guard let modelURL = Bundle.main.url(forResource: "Model", withExtension: "momd") else {
                return nil
            }
            
            guard let mom = NSManagedObjectModel(contentsOf: modelURL) else {
                return nil
            }
            
            let psc = NSPersistentStoreCoordinator(managedObjectModel: mom)
            let moc = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
            moc.persistentStoreCoordinator = psc
            
            let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            let persistantStoreFileURL =
                urls[0].appendingPathComponent("Bookmarks.sqlite")
                //urls[0].URLByAppendingPathComponent("Bookmarks.sqlite")
            
            do {
                try psc.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: persistantStoreFileURL, options: nil)
            } catch {
                fatalError("Error adding store.")
            }
            
            self.init(moc: moc)
        }
        
        func tagFeedItem(tagTitle: String, feedItem: FeedItem) {
            let tagsFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Tag")
            
            // cocoa predicate query -- not SQL
            tagsFetch.predicate = NSPredicate(format: "title == %@", tagTitle)
            
            var fetchedTags: [Tag]!
            do {
                fetchedTags = try self.managedObjectContext.fetch(tagsFetch) as! [Tag]
            } catch {
                fatalError("fetch failed")
            }
            
            var tag: Tag
            if fetchedTags.count == 0 {
                tag = NSEntityDescription.insertNewObject(forEntityName: "Tag", into: self.managedObjectContext) as! Tag
                tag.title = tagTitle
            } else {
                tag = fetchedTags[0]
            }
            
            let newImage = NSEntityDescription.insertNewObject(forEntityName: "Image", into: self.managedObjectContext) as! Image
            
            newImage.title = feedItem.title
            newImage.imageUrl = feedItem.imageURL.absoluteString
            newImage.tagLink = tag
            
            do {
                try self.managedObjectContext.save()
            } catch {
                fatalError("couldn't save context")
            }
        }
        
    }

