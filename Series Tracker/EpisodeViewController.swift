//
//  EpisodeViewController.swift
//  Series Tracker
//
//  Created by Nitish Krishna Ganesan on 9/26/15.
//  Copyright © 2015 NKG. All rights reserved.
//
import UIKit
import Alamofire

class EpisodeViewController: UIViewController {
    var episodeMarkAsSeen = [String: Int]()
    @IBOutlet weak
    var markSeen: UISwitch!
        @IBOutlet weak
    var theme1: UIImageView!
        @IBOutlet weak
    var episodeDesc: UILabel!
        @IBOutlet weak
    var episodeTitle: UILabel!
        @IBOutlet weak
    var airDate: UILabel!
        override func viewDidLoad() {

            super.viewDidLoad()
            let key = selectedid + String(selectedseason + 1) + String(selectedepisode + 1)
            var onoff = 0
            
            // retrieving the state of the markasseen button
            if NSUserDefaults.standardUserDefaults().objectForKey(key) != nil {
                episodeMarkAsSeen = NSUserDefaults.standardUserDefaults().objectForKey(key) as![String: Int]
                onoff = episodeMarkAsSeen[key] !
            }
            
            // setting the markasseen button according to the retrieved state
            if (onoff == 0) {
                markSeen.setOn(false, animated: true)
            } else {
                markSeen.setOn(true, animated: true)
            }

            let headers = ["application/json": "Accept"]
            let id = selectedid
            // retrieving the episode list
            if (reachability ? .isReachable() == false) {
                let msg = "Cellular Data is Turned Off"
                let alertController = UIAlertController(title: "Alert", message:
                    msg, preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", 
                style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alertController, animated: true, completion: nil)
            } else { 
                // getting list of seasons and episodes
                print("test")
                Alamofire.request(.GET, "http://api.themoviedb.org/3/tv/" + id + 
                "/season/" + String(selectedseason + 1) + "/episode/" + 
                String(selectedepisode + 1), parameters: ["api_key": "133c880eda26e631ff9b8810b963fffc"], 
                headers: headers)
                    .response {
                        (request, response, data, error) in
                        let json: AnyObject! =
                            try ? NSJSONSerialization.JSONObjectWithData(data!, 
                            options: NSJSONReadingOptions.MutableContainers)
                        print(json)
                        if let ret = json["air_date"] as ? String {
                            self.airDate.text = ret
                        }
                        if let ret = json["name"] as ? String {
                            self.episodeTitle.text = ret
                        }
                        if let ret = json["overview"] as ? String {
                            self.episodeDesc.text = ret
                        }
                        if let _ = json["still_path"] !as ? NSNull!{
                            print("no image")
                        }
                        if let _ = json["still_path"] !as ? String!{
                            //print(ret != <null>)
                            print("after here")
                            let imagepath = json["still_path"] as ? String
                            if let url = NSURL(string: "https://image.tmdb.org/t/p/original" + imagepath!) {
                                //print(url)
                                if let data = NSData(contentsOfURL: url) {
                                    let bach = UIImage(data: data)
                                    self.theme1.image = bach
                                }
                            }
                        }
                        else {
                            let paths: [AnyObject] = NSSearchPathForDirectoriesInDomains(
                                NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
                            let getImagePath1 = paths[0] as ? String
                            let getImagePath = getImagePath1!+"/" + selectedseries + ".jpg"
                            if paths.count > 0 {
                                let savePath = getImagePath
                                //print(savePath)
                                self.theme1.image = UIImage(named: savePath)
                            }
                        }

                    }

            }

        }
    @IBAction func markSeenButton(sender: AnyObject) {
        // storing the state of the markasseen button
        if markSeen.on {
            let key = selectedid + String(selectedseason + 1) + String(selectedepisode + 1)
            episodeMarkAsSeen[key] = 1
            NSUserDefaults.standardUserDefaults().setObject(episodeMarkAsSeen, forKey: key)
        } else {
            let key = selectedid + String(selectedseason + 1) + String(selectedepisode + 1)
            episodeMarkAsSeen[key] = 0
            NSUserDefaults.standardUserDefaults().setObject(episodeMarkAsSeen, forKey: key)
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