//
//  AppDelegate.swift
//  PersistenceLesson
//
//  Created by yeuchi on 6/19/20.
//  Copyright © 2020 yeuchi. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var dataController: DataController!
       var window: UIWindow?
       var viewController:ImageFeedTableViewController? = nil
    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        self.dataController = DataController()
        
        UserDefaults.standard.register(defaults: ["PhotoFeedURLString" : "https://www.flickr.com/services/feeds/photos_public.gne?tags=kitten&format=json&nojsoncallback=1"])
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "PersistenceLesson")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    // --- loading data ----------------
    
    func updateFeed(url: NSURL, completion: (_ feed: Feed?) -> Void) {
        let request = NSURLRequest(url: url as URL)
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) in
            
            if error != nil || data == nil {
                print("Client error!")
                return
            }

            guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
                print("Server error!")
                return
            }

            guard let mime = response.mimeType, mime == "application/json" else {
                print("Wrong MIME type!")
                return
            }

            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: [])
               // print(json)
                
                
                let feed = Feed(data: data as! NSData, sourceURL: url)
                
                if(feed != nil) {
                    if self.saveFeed(feed: feed!) {
                        // save date when feed is saved
                        UserDefaults.standard.set(NSDate(), forKey: "lastUpdate")
                    }
                    
                    if(self.viewController != nil) {
                        DispatchQueue.main.async {
                            self.viewController?.feed = feed
                        }
                    }
                    
                    print("loaded Remote feed!")
                }
                
            } catch {
                print("JSON error: \(error.localizedDescription)")
            }
        })
        task.resume()
    }
    
    func isCacheDataStale() -> Bool {
        let lastUpdatedSetting = UserDefaults.standard.object(forKey: "lastUpdate") as? NSDate
        
        // compare now with recorded time - last saved
        if(lastUpdatedSetting != nil){
            let timeInterval = NSDate().timeIntervalSince(lastUpdatedSetting as! Date)
            if timeInterval < 20 {
                return false
            }
        }
        return true
    }
    
    /*
     * Load data if stale
     */
    func loadOrUpdateFeed(url: NSURL, completion: (_ feed: Feed?) -> Void) {
        let shouldUpdate = isCacheDataStale()
        
        if shouldUpdate {
            self.updateFeed(url: url, completion: completion)
        }
        else {
            /*
             * load the saved file
             */
            let feed = self.readFeed()
            if(feed != nil) {
                if feed?.sourceURL.absoluteURL == url.absoluteURL {
                    print("loaded saved feed!")
                    return
                }
            }
            
            // if failed to read above, get fresh data from network
            self.updateFeed(url: url, completion: completion)
        }
    }
    
    /*
     * get a local cache file path
     */
    func feedFilePath() -> URL {
        // Request application cache or document directory
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let filePath = paths[0].appendingPathComponent("feedFile.plist")
        print(filePath)
        return filePath
    }
    
    /*
     * save the feed as cache file
     */
    func saveFeed(feed: Feed) -> Bool {
        do {
            let fileUrl = feedFilePath()
            let data = try NSKeyedArchiver.archivedData(withRootObject: feed, requiringSecureCoding: false)
            try data.write(to: fileUrl)
            UserDefaults.standard.set(fileUrl, forKey: "fileUrl")
            print(fileUrl)
            return true
        }
        catch {
            print("failed to write archive")
            return false
        }
    }
    
    /*
     * read the cache file back
     */
    func readFeed() -> Feed? {
        
        do {
            let fileUrl = UserDefaults.standard.url(forKey: "fileUrl")

            if(fileUrl != nil) {
                print(fileUrl)
                let data = try Data(contentsOf: fileUrl!)
                let object = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data)
                if object != nil {
                    return object as! Feed
                }
                print("read failed : nil")
            }
            print("no user defaults available")
            
        } catch {
            print("Couldn't read file.")
        }
        return nil
    }
}

