//
//  TableViewController.swift
//  Series Tracker
//
//  Created by Nitish Krishna Ganesan on 9/19/15.
//  Copyright © 2015 NKG. All rights reserved.
//

import UIKit
import CoreData
import Alamofire

struct Variables {
    static var sendData = [String]()
}
class TableViewController: UITableViewController, UISearchBarDelegate, UISearchDisplayDelegate {
    
    var sid = [String: Int]()
    @IBOutlet weak var searchbar: UISearchBar!
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    var tableData = [String]()
    var sendData = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        searchbar.delegate = self
        tableView.dataSource = self
        self.tableView.frame = CGRectMake(0,0,320,100)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.tableData.count
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        self.tableData.removeAll()
        let headers = ["application/json": "Accept"]
        let s:String = searchText
        if (searchText == ""){
            
        }else{
            if(reachability?.isReachable() == false){
                let msg = "Cellular Data is Turned Off"
                let alertController = UIAlertController(title: "Alert", message:
                    msg, preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
                self.presentViewController(alertController, animated: true, completion: nil)
            }else{
                Alamofire.request(.GET, "http://api.themoviedb.org/3/search/tv", parameters: ["api_key": "133c880eda26e631ff9b8810b963fffc","query": s ], headers:headers)
                    .response { (request, response, data, error) in
                        let json: AnyObject! = try? NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)
                        
                        //print(json)
                        let result = json["results"] as! [[String : AnyObject]]
                        for res in result {
                            let name = res["name"]! as! String
                            self.sid[name] = Int(res["id"]! as! NSNumber)
                            //print(self.sid[name])
                            self.tableData.append(name)
                        }
                        self.tableView.reloadData()
                }
            }
        }
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let indexPath = tableView.indexPathForSelectedRow;
        
        let currentCell = tableView.cellForRowAtIndexPath(indexPath!);
        print(currentCell!.textLabel!.text!)
        let lbl = currentCell!.textLabel!.text!
        if(series.contains(lbl)){
            let msg = "Already present in tracking list!"
            let alertController = UIAlertController(title: lbl, message:
                msg, preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
            self.presentViewController(alertController, animated: true, completion: nil)
        }else{
            series.append(lbl)
            seriesid[lbl] = sid[lbl]
            NSUserDefaults.standardUserDefaults().setObject(series, forKey: "series")
            NSUserDefaults.standardUserDefaults().setObject(seriesid, forKey: "seriesid")
            //saving image to local storage
            let headers = ["application/json": "Accept"]
            let id = String(seriesid[lbl]!)
            var imageurlarr = [String]()
            Alamofire.request(.GET, "http://api.themoviedb.org/3/tv/"+id+"/images", parameters: ["api_key": "133c880eda26e631ff9b8810b963fffc" ], headers:headers)
                .response { (request, response, data, error) in
                    
                    let json: AnyObject! = try? NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)
                    //print(json)
                    let result = json["backdrops"] as! [[String : AnyObject]]
                    for res in result {
                        imageurlarr.append(res["file_path"]! as! String)
                    }
                    if(imageurlarr.isEmpty){
                        imagepresent[lbl] = 0; //if image is not available
                        NSUserDefaults.standardUserDefaults().setObject(imagepresent, forKey: "imagepresent")
                        print(lbl)
                        print(imagepresent[lbl])
                    }else{
                        imagepresent[lbl] = 1;
                        NSUserDefaults.standardUserDefaults().setObject(imagepresent, forKey: "imagepresent")
                        let documentsDirectory:String?
                        let paths:[AnyObject] = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
                        if let url = NSURL(string: "https://image.tmdb.org/t/p/original" + imageurlarr[0]) {
                            print(url)
                            if let data1 = NSData(contentsOfURL: url) {
                                if paths.count > 0 {
                                    documentsDirectory = paths[0] as? String
                                    let savePath = documentsDirectory! + "/" + lbl + ".jpg"
                                    print(savePath)
                                    NSFileManager.defaultManager().createFileAtPath(savePath, contents: data1, attributes: nil)
                                }
                                //print("taken")
                            }
                        }
                        
                    }
            }

            //setting alert
            let msg = "Added to your tracking list!"
            let alertController = UIAlertController(title: lbl, message:
                msg, preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as UITableViewCell
        
        // Configure the cell
        if(tableData.count>0){
            cell.textLabel!.text = self.tableData[indexPath.row]
            cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        }
        return cell
    }
    
}
