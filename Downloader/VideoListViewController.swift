//
//  SecondViewController.swift
//  Downloader
//
//  Created by Bill Levien on 12/19/17.
//  Copyright © 2017 Bill Levien. All rights reserved.
//

import UIKit
import AVKit
import Foundation

class songsTableViewCell: UITableViewCell{

    @IBOutlet weak var videoTitle: UILabel!
    @IBOutlet weak var videoURL: UILabel!
}

class VideoListViewController: UIViewController,UITableViewDataSource, UITableViewDelegate {
   
    @IBOutlet var videoListView: UITableView!
    
    var song_list = [videoItem]()
    
    @IBOutlet weak var coverImage: UIImageView?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        tabBarItem.image = UIImage(named: "list")?.withRenderingMode(UIImageRenderingMode.automatic)
        tabBarItem.selectedImage = UIImage(named: "list")?.withRenderingMode(UIImageRenderingMode.automatic)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.coverImage?.backgroundColor = UIColor.black
        self.coverImage?.contentMode = .scaleAspectFit
        self.coverImage?.image = #imageLiteral(resourceName: "UncleWayne")
    }

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        videoListView.dataSource = self
        videoListView.delegate = self
        videoListView.register(songsTableViewCell.self,forCellReuseIdentifier: "Cell")
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let url = URL(string: "https://storage.googleapis.com/staging.uncle-wayne-196006.appspot.com/get_songs.json")!
        let task = session.dataTask(with: url) { (JSONdata, response, error) in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                
                do {
                    if let data = JSONdata,
                        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                        let songs = json["songs"] as? [[String: Any]] {
                        
                        self.song_list.removeAll()
                        
                        for song in songs {
                            self.song_list.append(videoItem(title: (song["title"]! as? String)!,
                                                            id: (String(describing: song["song_id"]!)),
                                                            image: (song["imageURL"]! as? String)!,
                                                            video: (song["videoURL"]! as? String)!))
                        }
                        DispatchQueue.main.async(){
                            self.videoListView.reloadData()
                        }
                    }
                    
                } catch {
                    print("Error deserializing JSON: \(error)")
                }
                
            }
            
        }
        task.resume()
        

    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return song_list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! songsTableViewCell
        
        let item = song_list[indexPath.row]
        let myDownloadsArray = UserDefaults.standard.array(forKey: "Downloads") as? [[String: String]]

        
        cell.videoTitle?.text = item.title
        cell.accessoryType = .none
        
        if myDownloadsArray != nil{ for video in myDownloadsArray!{
            if item.video == video["video"]{
            cell.accessoryType = .checkmark
            }
            }
        }
        
        

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "All Songs"
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        
        self.videoListView.isUserInteractionEnabled = false

        
        if let indexPath = self.videoListView.indexPathForSelectedRow{
            let video = song_list[indexPath.row]
            
            // Get Name for File
            let filename = video.video
            
            var downloaded = false
            let myDownloadsArray = UserDefaults.standard.array(forKey: "Downloads") as? [[String: String]]

            if myDownloadsArray != nil{
                for video in myDownloadsArray!{
                    if filename == video["video"]{
                        downloaded = true
                    }
                }
            }
            
            if !downloaded{
                let urlString = "https://storage.googleapis.com/staging.uncle-wayne-196006.appspot.com/" + filename
                
                // Create destination URL
                let fileManager = FileManager.default
                let documentsUrl:URL =  fileManager.urls(for: .documentDirectory, in: .userDomainMask).first as URL!
                let destinationFileUrl = documentsUrl.appendingPathComponent(filename)
                
            
                //Create URL to the source file you want to download
                let fileURL = URL(string: urlString)
            
                let sessionConfig = URLSessionConfiguration.default
                let session = URLSession(configuration: sessionConfig)
            
                let request = URLRequest(url:fileURL!)
            
                let task = session.downloadTask(with: request) { (tempLocalUrl, response, error) in
                    if let tempLocalUrl = tempLocalUrl, error == nil {
                        // Success
                        if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                            
                            print("Successfully downloaded. Status code: \(statusCode)")
                            
                            print("---Writing to Downloads---")
                            let myDownloadsArray = UserDefaults.standard.array(forKey: "Downloads") as? [[String: String]]

                            var tempDownloads = [[String: String]]()
                            if myDownloadsArray != nil{
                                tempDownloads = myDownloadsArray!
                            }
                            tempDownloads.append(["title":video.title, "id":video.id, "image":video.image, "video":video.video, "localURL":destinationFileUrl.absoluteString])
                            UserDefaults.standard.set(tempDownloads, forKey: "Downloads")
                            print(destinationFileUrl)
                            print("---------")
                            DispatchQueue.main.async(){
                                self.videoListView.reloadData()
                            }
                            
                        } else {
                            print("URL was bad")
                        }
                        
                        do {
                            try FileManager.default.copyItem(at: tempLocalUrl, to: destinationFileUrl)
                        } catch (let writeError) {
                            print("Error creating a file \(destinationFileUrl) : \(writeError)")
                        }
                    } else {
                        print("Error took place while downloading a file. Error description: %s", error?.localizedDescription as Any);
                    }
                    DispatchQueue.main.async{ self.videoListView.isUserInteractionEnabled = true}
                }
                
                task.resume()
            
            }
            else{
                self.videoListView.isUserInteractionEnabled = true
                print("Already Downloaded")
            }
            
        }
        
    }

}
