//
//  MainViewController.swift
//  mezi-flickr-photos
//
//  Created by Lokesh Basu on 21/11/16.
//  Copyright © 2016 mezi-flickr-photos. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    
    let apiEndpoint = "https://api.flickr.com/services/rest/?method=flickr.interestingness.getList&api_key=d98f34e2210534e37332a2bb0ab18887&format=json&extras=url_n&nojsoncallback=1"
    
    var allPhotoInfo = [PhotoRecord]()
    var allPhotosToBeRendered = [PhotoRecord]()
    let pendingOperations = PendingOperations()
    
    var screenWidth = 0.0;
    var screenHeight = 0.0;
    
    let testImagesName = "mezi"
    
    var yPosition:CGFloat = 0
    var imageContainerScrollViewContentHeight:CGFloat = 0.0
    
    @IBOutlet weak var imageContainerScrollView: UIScrollView!
    
    var batchStartIndex = 0
    
    var timer = Timer()
    
    var nextBatch = [Int]()
    
    var apiFetched = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getScreenDetails()
        
        getImageData()
    }
    
    func loadImages() {
        let batch = self.getBatchOfPhotos()
        if batch.count > 0 {
            self.downloadPhotosInBatch(batch: batch)
            self.displayPhotosInBatch(batch: batch)
            self.nextBatch.removeAll()
            self.nextBatch = self.getBatchOfPhotos()
            self.downloadPhotosInBatch(batch: self.nextBatch)
            self.timer = Timer.scheduledTimer(timeInterval: 10, target:self, selector: #selector(MainViewController.chekToRepeat), userInfo: nil, repeats: true)
        } else {
            print("No photos to display")
            self.timer.invalidate()
        }
    }
    
    func chekToRepeat() {
        print("Calling Timer")
        if (batchStartIndex < allPhotosToBeRendered.count-1) {
            if(self.nextBatch.count <= 0) {
                self.nextBatch = self.getBatchOfPhotos()
                self.downloadPhotosInBatch(batch: self.nextBatch)
            }
            self.displayPhotosInBatch(batch: self.nextBatch)
            self.nextBatch.removeAll()
            self.nextBatch = self.getBatchOfPhotos()
            self.downloadPhotosInBatch(batch: self.nextBatch)
        } else {
            print("Invalidate timer")
            self.timer.invalidate()
        }
    }
    
    func getBatchOfPhotos() -> [Int] {
        var totalImageHeight = 0.0
        var photosIndexesForBatch = [Int]()
        print("batchStartIndex: \(batchStartIndex)")
        while ((batchStartIndex < allPhotosToBeRendered.count-1) && (totalImageHeight + allPhotosToBeRendered[batchStartIndex].photoRenderingHeight) <= self.screenHeight) {
            totalImageHeight = totalImageHeight + allPhotosToBeRendered[batchStartIndex].photoRenderingHeight
            photosIndexesForBatch.append(batchStartIndex)
            batchStartIndex = batchStartIndex + 1
        }
        
        if (batchStartIndex >= allPhotosToBeRendered.count-1) {
            self.timer.invalidate()
        }
        
        return photosIndexesForBatch
    }
    
    func downloadPhotosInBatch(batch: [Int]) {
        for i in batch {
            while allPhotosToBeRendered[i].state != .downloaded {
                self.startOperationsForPhotoRecord(photoDetails: allPhotosToBeRendered[i], index: i)
            }
        }
    }
    
    func displayPhotosInBatch(batch: [Int]) {
        for i in batch {
            let imageWidth = allPhotosToBeRendered[i].photoRenderingWidth
            let imageHeight = allPhotosToBeRendered[i].photoRenderingHeight
            let image = allPhotosToBeRendered[i].image!
            
            print(allPhotosToBeRendered[i].image!)
            
            let imageView = UIImageView()
            
            imageView.image = image
            imageView.frame.size.height = CGFloat(imageHeight)
            imageView.frame.size.width = CGFloat(imageWidth)
            imageView.center = self.view.center
            imageView.frame.origin.y = yPosition
            
            self.imageContainerScrollView.addSubview(imageView)
            
            self.yPosition = self.yPosition + CGFloat(imageHeight)
            imageContainerScrollViewContentHeight = imageContainerScrollViewContentHeight + CGFloat(imageHeight)
            
            self.imageContainerScrollView.contentSize = CGSize(width: CGFloat(self.screenWidth), height: imageContainerScrollViewContentHeight)
        }
    }
    
    
    func getScreenDetails() {
        self.screenWidth = Double(self.view.bounds.width)
        self.screenHeight = Double(self.view.bounds.height)
    }
    
    func getImageData() {
        let session = URLSession(configuration: URLSessionConfiguration.default)
        
        let request = NSURLRequest(url: NSURL(string: self.apiEndpoint)! as URL)
        
        let task: URLSessionDataTask = session.dataTask(with: request as URLRequest) { (data, response, error) -> Void in
            do {
                let jsonData = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String:Any]
                let allPhotos = jsonData["photos"] as! [String:Any]
                let photosArray = allPhotos["photo"] as! [Any]
                for singlePhotoDetail in photosArray {
                    let singlePhotoDetailDictionary = singlePhotoDetail as! [String: Any]
                    let photoURL = singlePhotoDetailDictionary["url_n"] as! String
                    
                    var photoHeight = 0.0
                    var photoWidth = 0.0
                    
                    let photoHeightInt = singlePhotoDetailDictionary["height_n"] as? Int
                    let photoHeightString = singlePhotoDetailDictionary["height_n"] as? String
                    
                    if((photoHeightInt) != nil) {
                        photoHeight = Double(photoHeightInt!)
                    } else {
                        photoHeight = (photoHeightString! as NSString).doubleValue
                    }

                    let photoWidthInt = singlePhotoDetailDictionary["width_n"] as? Int
                    let photoWidthString = singlePhotoDetailDictionary["width_n"] as? String
                    
                    if((photoWidthInt) != nil) {
                        photoWidth = Double(photoWidthInt!)
                    } else {
                        photoWidth = (photoWidthString! as NSString).doubleValue
                    }
                    let photoDetailObject = PhotoRecord(photoURL: NSURL(string: photoURL)! as URL, photoOriginalHeight: photoHeight, photoOriginalWidth: photoWidth, photoRenderingHeight: photoHeight, photoRenderingWidth: photoWidth)
                    self.allPhotoInfo.append(photoDetailObject)
                }
                // If we have some photos from api request
                if(self.allPhotoInfo.count > 0) {
                    self.allPhotoInfo.sort { ($0.photoOriginalHeight) < ($1.photoOriginalHeight) }
                    
                    // Now set the rendering width to be a maximum of screen width if any image
                    // is having width more than screen, and scale height in same
                    // aspect ratio
                    for photoInfo in self.allPhotoInfo {
                        if(photoInfo.photoOriginalWidth > self.screenWidth) {
                            photoInfo.photoRenderingWidth = self.screenWidth
                            photoInfo.photoRenderingHeight = (photoInfo.photoOriginalHeight*photoInfo.photoRenderingWidth)/photoInfo.photoOriginalWidth
                        }
                    }
                    // Now rendering images with height <= than screen size
                    for photoInfo in self.allPhotoInfo {
                        if(photoInfo.photoRenderingHeight <= self.screenHeight) {
                            self.allPhotosToBeRendered.append(photoInfo)
                        }
                    }
                    self.apiFetched = true
                }
            } catch let error as NSError {
                print(error)
            }
        }
        task.resume()
        // Just a tweak for now
        while(true) {
            if(apiFetched) {
                print("API Fetched")
                break
            }
        }
        self.loadImages()
    }
    
    func downloadImages() {
        
    }
    
    
    func startOperationsForPhotoRecord(photoDetails: PhotoRecord, index: Int){
        switch (photoDetails.state) {
        case .new:
            self.startDownloadForRecord(photoDetails: photoDetails, index: index)
        default:
            print("Already downloaded.")
        }
    }
    
    func startDownloadForRecord(photoDetails: PhotoRecord, index: Int){
        if pendingOperations.downloadsInProgress[index] != nil {
            return
        }
        
        let downloader = ImageDownloader(photoRecord: photoDetails)
        downloader.completionBlock = {
            if downloader.isCancelled {
                return
            }
            DispatchQueue.main.async(execute: {
                self.pendingOperations.downloadsInProgress.removeValue(forKey: index)
//                print("Image is downloaded and can be set to be viewed: \(index)")
                self.view.setNeedsDisplay()
            })
        }
        pendingOperations.downloadsInProgress[index] = downloader
        pendingOperations.downloadQueue.addOperation(downloader)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
