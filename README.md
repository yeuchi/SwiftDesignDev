# SwiftDesignDev


## Course
Coursera University of Toronto iOS App Development with Swift Specialization Courses: \
Course 3 : App Design and Development for iOS with Professor Parham Aarabi. 
- Week 1 - 2 : UIScrollView pan & zoom, NavigationController, TabController with Jack Wu. 
- Week 3 : UserDefaults, cache, network and core data with Mike Spears. 

https://www.coursera.org/learn/ios-app-design-development

### Course Forum 
https://www.coursera.org/learn/ios-app-design-development/discussions

This is the 3rd course of the series, 4rd repository in Github. \
Previous 3 repositories are as follow. 

1. Swift5ImageProcessor - 1st course - image processing in Swift utilizing RGBA.swift
https://github.com/yeuchi/Swift5ImageProcessor

2. InstaFilter - 2nd course - culmunation of lessons. \
https://github.com/yeuchi/InstaFilterApp

3. SwiftDevBasic - 2nd course - final project. \
https://github.com/yeuchi/SwiftDevBasic/edit/master/README.md

## SwiftDesignDev10 Project
Due to some big constraint changes in XCode 11.1 StoryBoard, I opted to use XCode 10.1 for this lesson by Jack Wu.
It is perfectly compatible with XCode 11.1. 

### ScrollView for panning and zoom
Wow, XCode 11 autolayout with scrollview has gotten worse over the years; I thought it was just my ignorance.\
But apparently many iOS developers find consensus on Apple forum<sup>[3]</sup>. \ 
Thanks to Keith Harrison's article<sup>[1]</sup> which helps alot.

Apparently zoom has been broken in 2018 according the Apple Forum <sup>[3]</sup>. \
As a fix, Ron Kiffer's article offer the following extension. \ 
But why an extension to 'ALL' ViewController(s) when it is not a Sealed class ?
```
  extension ViewController {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
```
Also, Panning is broken in XCode 11.1, or at least it requires addition configuration on Framelayout Grid and Contentlayout Grid.
While I got it working, it is not free from constraint conflicts and warnings.  Check out Keith Harrison's article<sup>[1]</sup> for solution.

<img width="220" alt="Screen Shot 2020-06-12 at 6 15 50 PM" src="https://user-images.githubusercontent.com/1282659/84553174-f0239a80-acd8-11ea-88fc-41f4fca067d4.png"> <img width="220" alt="Screen Shot 2020-06-12 at 6 16 45 PM" src="https://user-images.githubusercontent.com/1282659/84553175-f0bc3100-acd8-11ea-9083-603a6accc1a4.png">

## NSUserDefault Project
Mike Spears offered a number of projects for his lessons; they are consolidated.

### UserDefaults
Key value pair persistence. \
<img width="220" alt="Screen Shot 2020-06-13 at 2 18 42 PM" src="https://user-images.githubusercontent.com/1282659/84577309-d8075600-ad80-11ea-817c-3b5060dda310.png">

### Setting
Settings.bundle -> Root.plist's UserDefaults are shared between OS Setting app and our application.
<img width="1117" alt="Screen Shot 2020-06-13 at 3 20 35 PM" src="https://user-images.githubusercontent.com/1282659/84578278-74cdf180-ad89-11ea-8b38-f0e8db2a7ae2.png">

<img width="220" alt="1" src="https://user-images.githubusercontent.com/1282659/84578219-f1140500-ad88-11ea-8d0a-045e044747d2.png"> <img width="220" alt="2" src="https://user-images.githubusercontent.com/1282659/84578221-f2453200-ad88-11ea-9d9f-b5ead65d51b6.png"> <img width="220" alt="3" src="https://user-images.githubusercontent.com/1282659/84578222-f40ef580-ad88-11ea-8f95-c2a5627a4d5b.png">

Some App delegate methods are deprecated.  The new method is to use SceneDelegate. <sup>[4]</sup> \
Namely our lesson's use of AppDelegate.applicationDidBecomeActive() is outdated.

<img width="784" alt="Screen Shot 2020-06-13 at 3 07 22 PM" src="https://user-images.githubusercontent.com/1282659/84578175-74812680-ad88-11ea-9fe8-88c76b9dc769.png">
<img width="788" alt="Screen Shot 2020-06-13 at 3 08 37 PM" src="https://user-images.githubusercontent.com/1282659/84578178-7ba83480-ad88-11ea-99b3-a44e9585f8d8.png">

### HTTP Request 
Some changes have been had in Swift 5.1 for asnyc network request. \
First, there is the addition of completionHandler. \
Second, there is an alternative to using NSOperationQueue.mainQueue().addOperationWithBlock() \
Reinder <sup>[5]</sup> does a pretty good job describing the process.

```
    func updateFeed(url: NSURL, completion: (_ feed: Feed?) -> Void) {
        let request = NSURLRequest(url: url as URL)
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) in
            
            if let data = data {
            //let feed = Feed(data: data as NSData, sourceURL: url)
                DispatchQueue.main.async {
                   let feed = Feed(data: data as NSData, sourceURL: url)
                }
            }
        })
        task.resume()
    }
```
-> Settings: Kittens, Pugs, Pizza \
<img width="220" alt="Screen Shot 2020-06-15 at 7 39 56 PM" src="https://user-images.githubusercontent.com/1282659/84719134-2747b500-af40-11ea-9837-fe1654adf966.png"> <img width="220" alt="Screen Shot 2020-06-15 at 7 43 26 PM" src="https://user-images.githubusercontent.com/1282659/84719286-94f3e100-af40-11ea-9d6e-b250ab24482e.png"> <img width="220" alt="Screen Shot 2020-06-15 at 7 43 57 PM" src="https://user-images.githubusercontent.com/1282659/84719289-96bda480-af40-11ea-969d-f734790bd11d.png">

### Cache data

NSKeyedArchiver has changed significantly since lesson.  Thanks to Paul Hudson<sup>[6]</sup> for the updated API.


## IDE
XCode 10.1 Swift 4.2

## References

1. Scroll View Layouts With Interface Builder by Keith Harrison, Sep 16, 2019 \
https://useyourloaf.com/blog/scroll-view-layouts-with-interface-builder/

2. UIScrollView Tutorial: Getting Started by Ron Kliffer, Nov 13 2019 \
https://www.raywenderlich.com/5758454-uiscrollview-tutorial-getting-started

3. iOS 12 scrollview zoom broken? Apple Forum latest reply by mbrown, Jul 5, 2018 3:39 AM \
https://forums.developer.apple.com/thread/103719

4. App delegate methods aren't being called in iOS 13 by Nevan King, June 8, 2019
https://stackoverflow.com/questions/56508764/app-delegate-methods-arent-being-called-in-ios-13

5. Networking In Swift With URLSession by Reinder de Vries on January 25 2019 \
https://learnappmaking.com/urlsession-swift-networking-how-to/

6. How to save and load objects with NSKeyedArchiver and NSKeyedUnarchiver by Paul Hudson, May 28th 2019 \
https://www.hackingwithswift.com/example-code/system/how-to-save-and-load-objects-with-nskeyedarchiver-and-nskeyedunarchiver
https://www.swiftdevcenter.com/save-and-get-objects-using-nskeyedarchiver-and-nskeyedunarchiver-swift-5/
