//
//  AppDelegate.swift
//  OptionOne
//
//  Created by yeuchi on 6/20/20.
//  Copyright © 2020 yeuchi. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var viewController:ImageFeedTableViewController? = nil

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UserDefaults.standard.register(defaults: ["PhotoFeedURLString" : "https://www.flickr.com/services/feeds/photos_public.gne?tags=kitten&format=json&nojsoncallback=1"])
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

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

