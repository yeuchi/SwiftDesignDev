//
//  ImageFeedTableViewController.swift
//  NSUserDefault
//
//  Created by yeuchi on 6/15/20.
//  Copyright © 2020 yeuchi. All rights reserved.
//

import UIKit
import CoreData

class ImageFeedTableViewController: UITableViewController {

    var urlString = "https://api.flickr.com/services/feeds/photos_public.gne?tags=kitten&format=json&nojsoncallback=1"
    
    
    var feed: Feed? {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    var urlSession: URLSession!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = URLSessionConfiguration.default
        self.urlSession = URLSession(configuration: configuration)
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.urlSession.invalidateAndCancel()
        self.urlSession = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.feed?.items.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ImageFeedItemTableViewCell", for: indexPath) as! ImageFeedItemTableViewCell

        let item = self.feed!.items[indexPath.row]
        cell.itemTitle.text = item.title

        let request = NSURLRequest(url: item.imageURL as URL)
            
        cell.dataTask = self.urlSession.dataTask(with: request as URLRequest) { (data, response, error) -> Void in
            OperationQueue.main.addOperation({ () -> Void in
                    if error == nil && data != nil {
                        let image = UIImage(data: data!)
                        cell.itemImageView.image = image
                    }
                })
            }

            cell.dataTask?.resume()
            
            return cell
        }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let item = self.feed!.items[indexPath.row]
        
        let alertController = UIAlertController(title: "Add Tag", message: "Type your tag", preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default) {(action)->Void in
            if let tagTitle = alertController.textFields?[0].text {
                let appDelegate = UIApplication.shared.delegate as! AppDelegate; appDelegate.dataController.tagFeedItem(tagTitle: tagTitle, feedItem: item)
            }
        }
        alertController.addAction(defaultAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        alertController.addTextField(configurationHandler: nil)
        self.present(alertController, animated:true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showTags" {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let moc = appDelegate.dataController.managedObjectContext
            
            let tagsVC = segue.destination as! TagsTableViewController
            
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Tag")
            request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
            
            tagsVC.fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil)
        }
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
