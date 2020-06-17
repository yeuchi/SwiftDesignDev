//
//  SceneDelegate.swift
//  NSUserDefault
//
//  Created by yeuchi on 6/13/20.
//  Copyright © 2020 yeuchi. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var viewController:ImageFeedTableViewController? = nil
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
        
        self.viewController = self.window?.rootViewController as! ImageFeedTableViewController
        if(self.viewController == nil) {
            print("don't have viewController ")
        }
        else {
            print("viewController is good !")
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
        
        let urlString = UserDefaults.standard.string(forKey: "PhotoFeedURLString")
        print(urlString)

        guard let foundURLString = urlString else {
            return
        }
        
        if let url = NSURL(string: foundURLString) {
            self.loadOrUpdateFeed(url: url, completion: { (feed) -> Void in

                //viewController?.feed = feed
                print("done sceneDidBecomeActive")
            })
        }
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
                print(json)
                
                
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

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
}

