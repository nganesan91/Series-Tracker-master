//
//  MovieSearch.swift
//  Series Tracker
//
//  Created by Nitish Krishna Ganesan on 9/23/15.
//  Copyright © 2015 NKG. All rights reserved.
//

import UIKit
import Alamofire

class MovieSearch: UITableViewController, UISearchBarDelegate, UISearchDisplayDelegate {

    var sid = [String: Int]()
    @IBOutlet weak
    var searchbar: UISearchBar!
    let managedObjectContext = (UIApplication.sharedApplication().delegate as!AppDelegate).managedObjectContext
    var tableData = [String]()
    var filteredData = [String]()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.searchbar.delegate = self
        self.tableView.dataSource = self
        self.tableView.frame = CGRectMake(0, 0, 320, 100)
        let headers = ["application/json": "Accept"]
        
        //checking for internet connection
        if (reachability ? .isReachable() == false) {
            let msg = "Cellular Data is Turned Off"
            let alertController = UIAlertController(title: "Alert", message:
                msg, preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", 
            style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alertController, animated: true, completion: nil)
        } else {
            
            // retrieving movie info
            Alamofire.request(.GET, "http://api.themoviedb.org/3/movie/upcoming", 
            parameters: ["api_key": "133c880eda26e631ff9b8810b963fffc"], headers: headers)
                .response {
                    (request, response, data, error) in
                    let json: AnyObject! =
                        try ? NSJSONSerialization.JSONObjectWithData(data!, 
                        options: NSJSONReadingOptions.MutableContainers)
                        
                    //print(json)
                    let result = json["results"] as![
                        [String: AnyObject]
                    ]
                    for res in result {
                        let name = res["original_title"] !as!String
                        moviereleasedate[name] = res["release_date"] !as!String
                        movieid[name] = res["id"] !as!Int
                        NSUserDefaults.standardUserDefaults().setObject(moviereleasedate, forKey: "moviereleasedate")

                        NSUserDefaults.standardUserDefaults().setObject(movieid, forKey: "movieid")
                        self.tableData.append(name)
                    }
                    self.tableView.reloadData()
                }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) - > Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) - > Int {
        // #warning Incomplete implementation, return the number of rows
        if tableView == self.searchDisplayController!.searchResultsTableView {
            return self.filteredData.count
        } else {
            return self.tableData.count
        }
    }

    func filterContentForSearchText(searchText: String) {
        // Filter the array using the filter method
        if (reachability ? .isReachable() == false) {
            let msg = "Cellular Data is Turned Off"
            let alertController = UIAlertController(title: "Alert", message:
                msg, preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", 
            style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alertController, animated: true, completion: nil)
        } else {
            self.filteredData = self.tableData.filter({
                (text: String) - > Bool in
                let stringMatch = text.lowercaseString.rangeOfString(searchText.lowercaseString)
                return (stringMatch != nil)
            })
        }
    }
    func searchDisplayController(controller: UISearchDisplayController, 
    shouldReloadTableForSearchString searchString: String ? ) - > Bool {
        self.filterContentForSearchText(searchString!)
        return true
    }

    func searchDisplayController(controller: UISearchDisplayController, 
    shouldReloadTableForSearchScope searchOption: Int) - > Bool {
        self.filterContentForSearchText(self.searchDisplayController!.searchBar.text!)
        return true
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) - > UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("cell1", forIndexPath: indexPath) 
        as UITableViewCell
        if tableView == self.searchDisplayController!.searchResultsTableView {
            cell.textLabel!.text = filteredData[indexPath.row]
        } else {
            cell.textLabel!.text = tableData[indexPath.row]
        }
        // Configure the cell
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        let indexPath = tableView.indexPathForSelectedRow;
        let currentCell = tableView.cellForRowAtIndexPath(indexPath!);
        print(currentCell!.textLabel!.text!)
        let lbl = currentCell!.textLabel!.text!
            if (movie.contains(lbl)) {
                let msg = "Already present in tracking list!"
                let alertController = UIAlertController(title: lbl, message:
                    msg, preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", 
                style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alertController, animated: true, completion: nil)
            } else {
                movie.append(lbl)
                NSUserDefaults.standardUserDefaults().setObject(movie, forKey: "movie")
                
                //saving image to local storage
                let headers = ["application/json": "Accept"]
                let id = String(movieid[lbl] !)
                var imageurlarr = [String]()
                Alamofire.request(.GET, "http://api.themoviedb.org/3/movie/" + id + "/images", 
                parameters: ["api_key": "133c880eda26e631ff9b8810b963fffc"], headers: headers)
                    .response {
                        (request, response, data, error) in

                        let json: AnyObject! =
                            try ? NSJSONSerialization.JSONObjectWithData(data!, 
                            options: NSJSONReadingOptions.MutableContainers)
                        //print(json)
                        let result = json["backdrops"] as![
                            [String: AnyObject]
                        ]
                        for res in result {
                            imageurlarr.append(res["file_path"] !as!String)
                        }
                        if (imageurlarr.isEmpty) {
                            imagepresentinmovie[lbl] = 0;
                            NSUserDefaults.standardUserDefaults().setObject(imagepresentinmovie, 
                            forKey: "imagepresentinmovie")
                            print(lbl)
                            print(imagepresentinmovie[lbl])
                        } else {
                            imagepresentinmovie[lbl] = 1;
                            NSUserDefaults.standardUserDefaults().setObject(imagepresentinmovie, 
                            forKey: "imagepresentinmovie")
                            let documentsDirectory: String ?
                                let paths: [AnyObject] = NSSearchPathForDirectoriesInDomains(
                                    NSSearchPathDirectory.DocumentDirectory, 
                                    NSSearchPathDomainMask.UserDomainMask, true)
                            if let url = NSURL(string: "https://image.tmdb.org/t/p/original" 
                            + imageurlarr[0]) {
                                print(url)
                                if let data1 = NSData(contentsOfURL: url) {
                                    if paths.count > 0 {
                                        documentsDirectory = paths[0] as ? String
                                        let savePath = documentsDirectory!+"/" + lbl + ".jpg"
                                        //print(savePath)
                                        NSFileManager.defaultManager().createFileAtPath(savePath, 
                                        contents: data1, attributes: nil)
                                    }
                                }
                            }

                        }
                    }
                    
                //setting alert
                let msg = "Added to your tracking list!"
                let alertController = UIAlertController(title: lbl, message:
                    msg, preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", 
                style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alertController, animated: true, completion: nil)
            }
    }

}