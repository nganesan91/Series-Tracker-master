//
//  BaseTableViewController.swift
//  Series Tracker
//
//  Created by Nitish Krishna Ganesan on 9/20/15.
//  Copyright © 2015 NKG. All rights reserved.

import Foundation
import SystemConfiguration
import UIKit
import Alamofire

var series = [String]()
var seriesid = [String: Int]()
var imagepresent = [String: Int]()
var selectedid: String = ""
var selectedseries: String = ""

let reachability = Reachability.reachabilityForInternetConnection()

class BaseTableViewController: UITableViewController, UISearchBarDelegate, UISearchDisplayDelegate {
    let managedObjectContext = (UIApplication.sharedApplication().delegate as!AppDelegate).managedObjectContext
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        if NSUserDefaults.standardUserDefaults().objectForKey("series") != nil {
            series = NSUserDefaults.standardUserDefaults().objectForKey("series") as![String]
            seriesid = NSUserDefaults.standardUserDefaults().objectForKey("seriesid") as![String: Int]
            imagepresent = NSUserDefaults.standardUserDefaults().objectForKey("imagepresent") as![String: Int]
        }
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.tableView.reloadData()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {

        if editingStyle == UITableViewCellEditingStyle.Delete {
            let lbl = series[indexPath.row]
            series.removeAtIndex(indexPath.row)
            seriesid.removeValueForKey(lbl)
            NSUserDefaults.standardUserDefaults().setObject(series, forKey: "series")
            NSUserDefaults.standardUserDefaults().setObject(seriesid, forKey: "seriesid")
            self.tableView.reloadData()
        }
    }
    override func numberOfSectionsInTableView(tableView: UITableView) - > Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) - > Int {
        // #warning Incomplete implementation, return the number of rows
        return series.count
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        let indexPath = tableView.indexPathForSelectedRow;
        let currentCell = tableView.cellForRowAtIndexPath(indexPath!);
        print(currentCell!.textLabel!.text!)
        print(seriesid[currentCell!.textLabel!.text!])
        selectedid = String(seriesid[series[indexPath!.row]] !)
        selectedseries = String(currentCell!.textLabel!.text!)
        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let destination = storyboard.instantiateViewControllerWithIdentifier("tvseriescontroller") 
        as!TvSeasonsController
        navigationController ? .pushViewController(destination, animated: true)

    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) - > UITableViewCell     {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("cell", 
        forIndexPath: indexPath) as UITableViewCell
        let headers = ["application/json": "Accept"]
        let id = String(seriesid[series[indexPath.row]] !)
        var imageurlarr = [String]()
        var count = -1

        var paths: [AnyObject] = NSSearchPathForDirectoriesInDomains(
            NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        let getImagePath1 = paths[0] as ? String
        let getImagePath = getImagePath1!+"/" + series[indexPath.row] + ".jpg"
        let checkValidation = NSFileManager.defaultManager()
        if (checkValidation.fileExistsAtPath(getImagePath)) {
            // checking if the image is present in the local storage
            let paths: [AnyObject] = NSSearchPathForDirectoriesInDomains(
                NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
            if paths.count > 0 {
                let savePath = getImagePath
                //print(savePath)
                cell.imageView ? .image = UIImage(named: savePath)
            }
        } else {
            //retrieving image if it is not present in the local storage)
            if (imagepresent[series[indexPath.row]] == 1) {
                //print("FILE NOT AVAILABLE");
                Alamofire.request(.GET, "http://api.themoviedb.org/3/tv/" + id 
                + "/images", parameters: ["api_key": "133c880eda26e631ff9b8810b963fffc"], headers: headers)
                    .response {
                        (request, response, data, error) in

                        let json: AnyObject! =
                            try ? NSJSONSerialization.JSONObjectWithData(
                                data!, options: NSJSONReadingOptions.MutableContainers)

                        //print(json)
                        let result = json["backdrops"] as![
                            [String: AnyObject]
                        ]
                        for res in result {
                            imageurlarr.append(res["file_path"] !as!String)
                            count++
                        }
                        if (imageurlarr.isEmpty) {
                        } else {
                            if let url = NSURL(string: "https://image.tmdb.org/t/p/original" + imageurlarr[0]) {
                                //print(url)
                                if let data = NSData(contentsOfURL: url) {
                                    let bach = UIImage(data: data)
                                    cell.imageView ? .image = bach
                                }
                            }
                        }
                    }
            } else {
                let imageName = "seriesicon.png"
                let image1 = UIImage(named: imageName)
                cell.imageView ? .image = image1
            }
        }
        cell.textLabel!.text = series[indexPath.row]
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        return cell
    }
}