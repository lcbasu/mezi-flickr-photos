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
    
    var allPhotoInfo = [PhotoInfo]()
    var allPhotosToBerendered = [PhotoInfo]()
    
    var screenWidth = 0.0;
    var screenHeight = 0.0;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getScreenDetails();
        getImageData();
        
        print("screenWidth: \(screenWidth)")
        print("screenHeight: \(screenHeight)")
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
                    let photoDetailObject = PhotoInfo(photoURL: photoURL, photoOriginalHeight: photoHeight, photoOriginalWidth: photoWidth, photoRenderingHeight: photoHeight, photoRenderingWidth: photoWidth)
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
                            self.allPhotosToBerendered.append(photoInfo)
                        }
                    }
                }
            } catch let error as NSError {
                print(error)
            }
        }
        task.resume()
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
