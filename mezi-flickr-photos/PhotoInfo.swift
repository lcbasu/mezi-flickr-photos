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
    var photoHeight: Int
    var photoWidth: Int
    
    init(photoURL: String, appointmentBookingDate: String, photoHeight: Int, photoWidth: Int) {
        self.photoURL = photoURL
        self.photoHeight = photoHeight
        self.photoWidth = photoWidth
    }
}

