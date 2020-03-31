//
//  let secondViewController = self.storyboard.instantiateViewControllerWithIdentifier("storyBoardIdFor your new ViewController") as SecondViewController  self.navigationController.pushViewController(secondViewController, animated- true).swift
//  Series Tracker
//
//  Created by Nitish Krishna Ganesan on 9/21/15.
//  Copyright © 2015 NKG. All rights reserved.
//
import UIKit
import Alamofire

var selectedseason:Int = 0
var selectedepisode:Int = 0
class TvSeasonsController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    var episode_count = [Int:Int]()
    var season_count = [Int]()
    @IBOutlet weak var customtableview: UITableView!
    @IBOutlet weak var theme: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.customtableview.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        customtableview.delegate = self
        customtableview.dataSource = self
        let headers = ["application/json": "Accept"]
        let id = selectedid
        //new
        
        var paths:[AnyObject] = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        let getImagePath1 = paths[0] as? String
        let getImagePath = getImagePath1! + "/" + selectedseries + ".jpg"
        if paths.count > 0 {
            let savePath = getImagePath
            //print(savePath)
            self.theme.image = UIImage(named: savePath)
        }
        // retrieving the episode list
        if(reachability?.isReachable() == false){
            let msg = "Cellular Data is Turned Off"
            let alertController = UIAlertController(title: "Alert", message:
                msg, preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
            self.presentViewController(alertController, animated: true, completion: nil)
        }
        else
        {   // getting list of seasons and episodes
            Alamofire.request(.GET, "http://api.themoviedb.org/3/tv/"+id, parameters: ["api_key": "133c880eda26e631ff9b8810b963fffc" ], headers:headers)
                .response { (request, response, data, error) in
                    
                    let json: AnyObject! = try? NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)
                    
                    //print(json)
                    let result = json["seasons"] as! [[String : AnyObject]]
                    for res in result {
                        let epi = res["episode_count"]! as! Int
                        let season = res["season_number"]! as! Int
                        print(epi)
                        print(season)
                        if(season != 0){
                            self.episode_count[season] = epi
                            self.season_count.append(season)
                        }
                    }
                    self.customtableview.reloadData()
            }
            
        }
        
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return season_count.count
    }
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        return "Season "+String(section+1)
    }
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView //recast your view as a UITableViewHeaderFooterView
        header.contentView.backgroundColor = UIColor(red: 150/255, green: 150/255, blue: 100/255, alpha: 1.0) //make the background color light blue
        header.textLabel!.textColor = UIColor.blackColor() //make the text white
        header.alpha = 0.5 //make the header transparent
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(episode_count.count>0){
            return episode_count[section+1]!
        }
        return season_count.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.customtableview.dequeueReusableCellWithIdentifier("cell2", forIndexPath: indexPath) as UITableViewCell
        cell.opaque = false
        //cell.backgroundColor = [UIColor colorWithRed:0 green:0.39 blue:0.106 alpha:0]
        // Configure the cell
        if(season_count.count>0){
            cell.textLabel!.text = "    Episode "+String(indexPath.row+1)
            cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let indexPath = tableView.indexPathForSelectedRow;
        let currentCell = tableView.cellForRowAtIndexPath(indexPath!);
        print(currentCell!.textLabel!.text!)
        selectedseason = indexPath!.section
        selectedepisode = indexPath!.row
        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let destination = storyboard.instantiateViewControllerWithIdentifier("EpisodeViewController") as! EpisodeViewController
        navigationController?.pushViewController(destination, animated: true)
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func shouldAutorotate() -> Bool {
        return false
    }
}
