//
//  ImageFeedCollectionViewController.swift
//  FirstTV
//
//  Created by Mike Spears on 2016-01-11.
//  Copyright © 2016 YourOganisation. All rights reserved.
//

import UIKit

private let reuseIdentifier = "ImageCell"

class ImageFeedCollectionViewController: UICollectionViewController {

    var urlString = "https://api.flickr.com/services/feeds/photos_public.gne?tags=kitten&format=json&nojsoncallback=1"
    
    var feed: Feed?  {
        didSet {
            self.collectionView?.reloadData()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.feed = nil
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        if let url = NSURL(string: urlString) {
            appDelegate.viewController = self
            appDelegate.loadOrUpdateFeed(url: url, completion: { (feed) -> Void in
                //self.feed = feed
            })
        }
    }

     func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return self.feed?.items.count ?? 0
    }

/*
    Thread 1: Exception: "the collection view's data source did not return a valid cell from -collectionView:cellForItemAtIndexPath: for index path <NSIndexPath: 0xf35ddf1161776718> {length = 2, path = 0 - 0}"
 */
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
       
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath as IndexPath) as! ImageCollectionViewCell
        
            let item = self.feed!.items[indexPath.row]

            cell.title.text = item.title
            
            let request = NSURLRequest(url: item.imageURL as URL)
            
            cell.dataTask = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) -> Void in
                OperationQueue.main.addOperation({ () -> Void in
                    if error == nil && data != nil {
                        let image = UIImage(data: data!)
                        cell.imageView.image = image
                    }
                })
            }
            cell.dataTask?.resume()
            return cell
    }
    
    /*
    Thread 1: Exception: "could not dequeue a view of kind: UICollectionElementKindCell with identifier ImageCell - must register a nib or a class for the identifier or connect a prototype cell in a storyboard"
    */
    func collectionView(collectionView: UICollectionView, didEndDisplayingCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        if let cell = cell as? ImageCollectionViewCell {
            cell.dataTask?.cancel()
            cell.imageView.image = nil
        }
    }
    
   

}
