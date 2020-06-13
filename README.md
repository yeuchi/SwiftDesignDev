# SwiftDesignDev


## Course
Coursera University of Toronto iOS App Development with Swift Specialization Courses: \
Course 3 : App Design and Development for iOS with Professor Parham Aarabi. 
- Week 1 - 2 : UIScrollView pan & zoom, NavigationController, TabController with Jack Wu. 
- Week 3 : UserDefaults (equivalent of SharedPreference on Android) with Mike Spears. 

https://www.coursera.org/learn/ios-app-design-development

### Course Forum 
https://www.coursera.org/learn/ios-app-design-development/discussions

This is the 2nd course of the series, 3rd repository in Github. \
Previous 2 repositories are as follow. 

1. Swift5ImageProcessor - 1st course - image processing in Swift utilizing RGBA.swift
https://github.com/yeuchi/Swift5ImageProcessor

2. InstaFilter - 2nd course - culmunation of lessons. \
https://github.com/yeuchi/InstaFilterApp

3. SwiftDevBasic - 2nd course - final project. \
https://github.com/yeuchi/SwiftDevBasic/edit/master/README.md

### ScrollView for panning and zoom
Wow, XCode 11 autolayout with scrollview is terrible and I thought it was just my ignorance.
But apparently many season iOS developers find consensus.  Thanks to Keith Harrison's article<sup>[1]</sup> which helps alot.

Apparently zoom has been broken in 2018 according the Apple Forum <sup>[3]</sup>.
As a fix, Ron Kiffer's article offer the following extension.
```
  extension ViewController {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
```
Panning is broken in XCode 11.1, or at least it requires addition configuration on Framelayout Grid and Contentlayout Grid.
While I got it working, it is not free from constraint conflicts and warnings.  Check out Keith Harrison's article<sup>[1]</sup> for solution.

<img width="220" alt="Screen Shot 2020-06-12 at 6 15 50 PM" src="https://user-images.githubusercontent.com/1282659/84553174-f0239a80-acd8-11ea-88fc-41f4fca067d4.png"> <img width="220" alt="Screen Shot 2020-06-12 at 6 16 45 PM" src="https://user-images.githubusercontent.com/1282659/84553175-f0bc3100-acd8-11ea-9083-603a6accc1a4.png">

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
