//
//  PhotoOperations.swift
//  mezi-flickr-photos
//
//  Created by Lokesh Basu on 23/11/16.
//  Copyright © 2016 mezi-flickr-photos. All rights reserved.
//

import Foundation
import UIKit

// This enum contains all the possible states a photo record can be in
enum PhotoRecordState {
    case new, downloaded, failed
}

class PhotoRecord {
    
    var photoURL: URL
    var photoOriginalHeight: Double
    var photoOriginalWidth: Double
    var photoRenderingHeight: Double
    var photoRenderingWidth: Double
    var state = PhotoRecordState.new
    var image = UIImage(named: "mezi")
    
    init(photoURL: URL, photoOriginalHeight: Double, photoOriginalWidth: Double, photoRenderingHeight: Double, photoRenderingWidth: Double) {
        self.photoURL = photoURL
        self.photoOriginalHeight = photoOriginalHeight
        self.photoOriginalWidth = photoOriginalWidth
        self.photoRenderingHeight = photoRenderingHeight
        self.photoRenderingWidth = photoRenderingWidth
    }
}


class PendingOperations {
    lazy var downloadsInProgress = [Int:Operation]()
    lazy var downloadQueue:OperationQueue = {
        var queue = OperationQueue()
        queue.name = "Download queue"
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
}

class ImageDownloader: Operation {
    let photoRecord: PhotoRecord
    init(photoRecord: PhotoRecord) {
        self.photoRecord = photoRecord
    }
    override func main() {
        if self.isCancelled {
            return
        }
        let imageData = try? Data(contentsOf: self.photoRecord.photoURL)
        if self.isCancelled {
            return
        }
        if (imageData?.count)! > 0 {
            self.photoRecord.image = UIImage(data:imageData!)
            self.photoRecord.state = .downloaded
        }
        else {
            self.photoRecord.state = .failed
            self.photoRecord.image = UIImage(named: "mezi")
        }
    }
}
