//
//  VideoItem.swift
//
//  Created by Bill Levien on 10/2/17.
//  Copyright © 2017 Uncle Wayne. All rights reserved.
//

import UIKit

class videoItem: NSObject {
    // Video Details
    var title: String
    var id: String
    var image: String
    var video: String
    
    
    // Returns a Video Object
    init(title: String, id: String, image: String, video: String) {
        self.title = title
        self.id = id
        self.image = image
        self.video = video
    }
    
}

