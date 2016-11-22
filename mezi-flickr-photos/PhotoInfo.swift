//
//  PhotoInfo.swift
//  mezi-flickr-photos
//
//  Created by Lokesh Basu on 21/11/16.
//  Copyright © 2016 mezi-flickr-photos. All rights reserved.
//

import Foundation

class PhotoInfo {
    
    var photoURL: String
    var photoOriginalHeight: Double
    var photoOriginalWidth: Double
    var photoRenderingHeight: Double
    var photoRenderingWidth: Double
    
    init(photoURL: String, photoOriginalHeight: Double, photoOriginalWidth: Double, photoRenderingHeight: Double, photoRenderingWidth: Double) {
        self.photoURL = photoURL
        self.photoOriginalHeight = photoOriginalHeight
        self.photoOriginalWidth = photoOriginalWidth
        self.photoRenderingHeight = photoRenderingHeight
        self.photoRenderingWidth = photoRenderingWidth
    }
}

