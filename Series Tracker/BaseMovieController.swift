//
//  BaseViewTableTableViewController.swift
//  Series Tracker
//
//  Created by Nitish Krishna Ganesan on 9/23/15.
//  Copyright © 2015 NKG. All rights reserved.
//

import UIKit
import Alamofire

var movie = [String]()
var movieid = [String: Int]()
var moviereleasedate = [String: String]()
var imagepresentinmovie = [String: Int]()
var selectedmovieid: String = ""
var selectedmovie: String = ""

class BaseMovieController: UITableViewController {

    let managedObjectContext = (UIApplication.sharedApplication().delegate as!AppDelegate).managedObjectContext
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        // retrieving the saved state
        if NSUserDefaults.standardUserDefaults().objectForKey("movie") != nil {
            movie = NSUserDefaults.standardUserDefaults().objectForKey("movie") as![String]
            movieid = NSUserDefaults.standardUserDefaults().objectForKey("movieid") as![String: Int]
            imagepresentinmovie = 
            NSUserDefaults.standardUserDefaults().objectForKey("imagepresentinmovie") as![String: Int]
            moviereleasedate = 
            NSUserDefaults.standardUserDefaults().objectForKey("moviereleasedate") as![String: String]

        }
    }
    override func tableView(tableView: UITableView, 
    commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        // enabling delete option for the added movies
        if editingStyle == UITableViewCellEditingStyle.Delete {
            let lbl = movie[indexPath.row]
            movie.removeAtIndex(indexPath.row)
            movieid.removeValueForKey(lbl)
            NSUserDefaults.standardUserDefaults().setObject(movie, forKey: "movie")
            NSUserDefaults.standardUserDefaults().setObject(movieid, forKey: "movieid")
            self.tableView.reloadData()
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.tableView.reloadData()
    }
    override func numberOfSectionsInTableView(tableView: UITableView) - > Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) - > Int {
        // #warning Incomplete implementation, return the number of rows
        return movie.count
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        let indexPath = tableView.indexPathForSelectedRow;
        let currentCell = tableView.cellForRowAtIndexPath(indexPath!);
        //print(currentCell!.textLabel!.text!)
        //print(movieid[currentCell!.textLabel!.text!])
        // saving the selected cell and opening a new controller
        selectedmovie = String(currentCell!.textLabel!.text!)
        selectedmovieid = String(movieid[selectedmovie] !)
        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let destination = storyboard.instantiateViewControllerWithIdentifier("movieDetail") as!MovieDetail
        navigationController ? .pushViewController(destination, animated: true)

    }

    override func tableView(tableView: UITableView, 
    cellForRowAtIndexPath indexPath: NSIndexPath) - > UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) 
        as UITableViewCell

        let headers = ["application/json": "Accept"]
        let id = String(movieid[movie[indexPath.row]] !)
        var imageurlarr = [String]()
        var count = -1
        var paths: [AnyObject] = NSSearchPathForDirectoriesInDomains(
            NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        let getImagePath1 = paths[0] as ? String
        let getImagePath = getImagePath1!+"/" + movie[indexPath.row] + ".jpg"
        // checking if the image exists in the local storage
        let checkValidation = NSFileManager.defaultManager()
        if (checkValidation.fileExistsAtPath(getImagePath)) {
            //print("FILE AVAILABLE");
            let paths: [AnyObject] = NSSearchPathForDirectoriesInDomains(
                NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
            if paths.count > 0 {
                let savePath = getImagePath
                //print(savePath)
                cell.imageView ? .image = UIImage(named: savePath)
            }
        } else {
            // retrieving the image for the api
            if (imagepresentinmovie[movie[indexPath.row]] == 1) {
                //print("FILE NOT AVAILABLE");
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
                let imageName = "Movies.jpg"
                let image1 = UIImage(named: imageName)
                cell.imageView ? .image = image1
            }
        }
        // calculating remaining days for movie release
        let date: String = moviereleasedate[movie[indexPath.row]] !
            let start = NSDate()
        let end = date
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let startDate: NSDate = start
        let endDate: NSDate = dateFormatter.dateFromString(end) !
            let cal = NSCalendar.currentCalendar()
        let unit: NSCalendarUnit = NSCalendarUnit.Day
        let components = cal.components(unit, fromDate: startDate, toDate: endDate, options: [])
        cell.textLabel!.text = movie[indexPath.row]
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator

        return cell
    }
}