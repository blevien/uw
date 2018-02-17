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

class DownloadListViewController: UIViewController, AVPlayerViewControllerDelegate {
    
    @IBOutlet weak var videoLabel: UILabel!
    
    var myDownloadsArray = UserDefaults.standard.array(forKey: "Downloads") as? [[String: String]]

    override func viewDidLoad(){
        super.viewDidLoad()
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        myDownloadsArray = UserDefaults.standard.array(forKey: "Downloads") as? [[String: String]]
        
        print("--Reading From Local Downloads---")
        if (myDownloadsArray != nil){
            for download in myDownloadsArray!{
                print(download)}
            videoLabel.text =  myDownloadsArray?[2]["title"]
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let destination = segue.destination as!AVPlayerViewController

        let fm = FileManager.default
        let docsurl = try! fm.url(for:.documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let myurl = docsurl.appendingPathComponent(myDownloadsArray![2]["video"]!)
        print(myurl)
        destination.player = AVPlayer(url: myurl)
        destination.player?.playImmediately(atRate: 1.0)
        
    }
    
    @IBAction func playVideo(_ sender: Any) {
            
    }
    
}

