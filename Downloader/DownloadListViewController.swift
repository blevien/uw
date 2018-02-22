//
//  FirstViewController.swift
//  Downloader
//
//  Created by Bill Levien on 12/19/17.
//  Copyright © 2017 Bill Levien. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class downloadsTableViewCell: UITableViewCell{
    @IBOutlet weak var downloadTitle: UILabel!
    
}

class DownloadListViewController: UIViewController,UITableViewDataSource, UITableViewDelegate, AVPlayerViewControllerDelegate {
    

    @IBOutlet weak var downloadsCoverImage: UIImageView!
    @IBOutlet weak var downloadListView: UITableView!

    var downloads_list = UserDefaults.standard.array(forKey: "Downloads") as? [[String: String]]
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        tabBarItem.image = UIImage(named: "list")?.withRenderingMode(UIImageRenderingMode.automatic)
        tabBarItem.selectedImage = UIImage(named: "list")?.withRenderingMode(UIImageRenderingMode.automatic)
    }
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        self.downloadsCoverImage?.backgroundColor = UIColor.black
        self.downloadsCoverImage?.contentMode = .scaleAspectFit
        self.downloadsCoverImage?.image = #imageLiteral(resourceName: "UncleWayne")
        
        downloads_list = UserDefaults.standard.array(forKey: "Downloads") as? [[String: String]]
        tabBarItem.image = UIImage(named: "play")?.withRenderingMode(UIImageRenderingMode.automatic)
        tabBarItem.selectedImage = UIImage(named: "play")?.withRenderingMode(UIImageRenderingMode.automatic)
        
        
        self.downloadListView.dataSource = self
        self.downloadListView.delegate = self
        self.downloadListView.register(downloadsTableViewCell.self,forCellReuseIdentifier: "Cell")

    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.downloadListView.isUserInteractionEnabled = true
        
        print("--Reading From Local Downloads---")
        downloads_list = UserDefaults.standard.array(forKey: "Downloads") as? [[String: String]]
        if (downloads_list != nil){
            for download in downloads_list!{
                print(download)}
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.async(){
            self.downloadListView.reloadData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let destination = segue.destination as!AVPlayerViewController
        downloads_list = UserDefaults.standard.array(forKey: "Downloads") as? [[String: String]]
        
        let fm = FileManager.default
        let docsurl = try! fm.url(for:.documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let myurl = docsurl.appendingPathComponent(downloads_list![(self.downloadListView.indexPathForSelectedRow?.row)!]["video"]!)
        print(myurl)
        destination.player = AVPlayer(url: myurl)
        destination.player?.playImmediately(atRate: 1.0)
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if downloads_list?.count != nil {
            return (downloads_list?.count)!
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        downloads_list = UserDefaults.standard.array(forKey: "Downloads") as? [[String: String]]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! downloadsTableViewCell
        let item = downloads_list![indexPath.row]
        
        cell.downloadTitle?.text =  item["title"]!

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        
        self.downloadListView.isUserInteractionEnabled = false
        
        performSegue(withIdentifier: "playDownload", sender: Any?.self)
        }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "My Downloads"
    }
}

