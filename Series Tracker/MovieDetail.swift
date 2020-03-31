//
//  movieDetail.swift
//  Series Tracker
//
//  Created by Nitish Krishna Ganesan on 9/24/15.
//  Copyright © 2015 NKG. All rights reserved.
//
import UIKit
import Foundation
import Alamofire
import CoreData

class MovieDetail: UIViewController {

    var movieFollow = [String: Int]()
    @IBOutlet weak
    var theme: UIImageView!
        @IBOutlet weak
    var follow: UISwitch!
        @IBOutlet weak
    var label3: UILabel!
        @IBOutlet weak
    var label2: UILabel!
        @IBAction func followclicked(sender: AnyObject) {
            // storing the state of the follow button
            if follow.on {
                let key = selectedmovieid
                movieFollow[key] = 1
                NSUserDefaults.standardUserDefaults().setObject(movieFollow, forKey: key)
                
                //setting notification at one day prior to the movie release date
                let date: String = moviereleasedate[selectedmovie] !
                    let start = NSDate()
                let end = date
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                let startDate: NSDate = start
                let endDate: NSDate = dateFormatter.dateFromString(end) !
                    let cal = NSCalendar.currentCalendar()
                let unit: NSCalendarUnit = NSCalendarUnit.Day
                let components = cal.components(unit, fromDate: startDate, toDate: endDate, options: [])
                let seconds: Double = Double(components.day * 86400)
                let localNotification = UILocalNotification()
                localNotification.timeZone = NSTimeZone.localTimeZone()
                UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
                localNotification.alertAction = selectedmovie
                localNotification.alertBody = selectedmovie + " Releasing tomorrow!"
                localNotification.fireDate = NSDate().dateByAddingTimeInterval(seconds)
                UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
            } else {
                let key = selectedmovieid
                movieFollow[key] = 0
                NSUserDefaults.standardUserDefaults().setObject(movieFollow, forKey: key)
            }
        }
    @IBOutlet weak
    var label1: UILabel!
        override func viewDidLoad() {
            super.viewDidLoad()
            let key = selectedmovieid
            var onoff = 0
            
            // retrieving the state of the follow button
            if NSUserDefaults.standardUserDefaults().objectForKey(key) != nil {
                movieFollow = NSUserDefaults.standardUserDefaults().objectForKey(key) as![String: Int]
                onoff = movieFollow[key] !
            }
            
            // setting the follow button according to the retrieved state
            if (onoff == 0) {
                follow.setOn(false, animated: true)
            } else {
                follow.setOn(true, animated: true)
            }
            let headers = ["application/json": "Accept"]
            let id = selectedmovieid
            
            //setting movie image
            var paths: [AnyObject] = NSSearchPathForDirectoriesInDomains(
                NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
            let getImagePath1 = paths[0] as ? String
            let getImagePath = getImagePath1!+"/" + selectedmovie + ".jpg"
            if paths.count > 0 {
                let savePath = getImagePath
                //print(savePath)
                self.theme.image = UIImage(named: savePath)
            }
            
            //getting movie details
            if (reachability ? .isReachable() == false) {
                let msg = "Cellular Data is Turned Off"
                let alertController = UIAlertController(title: "Alert", message:
                    msg, preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", 
                style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alertController, animated: true, completion: nil)
            } else {
                Alamofire.request(.GET, "http://api.themoviedb.org/3/movie/" + id, 
                parameters: ["api_key": "133c880eda26e631ff9b8810b963fffc"], headers: headers)
                    .response {
                        (request, response, data, error) in
                        let json: AnyObject! =
                            try ? NSJSONSerialization.JSONObjectWithData(data!, 
                            options: NSJSONReadingOptions.MutableContainers)
                        //print(json)
                        if let ret = json["release_date"] as ? String {
                            self.label1.text = ret
                        }
                        self.label2.text = selectedmovie
                        if let ret = json["overview"] as ? String {
                            self.label3.text = String(ret)
                        }
                    }
            }

        }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func shouldAutorotate() - > Bool {
        return false
    }
}