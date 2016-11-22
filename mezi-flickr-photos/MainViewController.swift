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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Inside Main View Controller")
        
        getImageData();
    }
    
    func getImageData() {
        let session = URLSession(configuration: URLSessionConfiguration.default)
        
        let request = NSURLRequest(url: NSURL(string: self.apiEndpoint)! as URL)
        
        let task: URLSessionDataTask = session.dataTask(with: request as URLRequest) { (data, response, error) -> Void in
            do {
                let jsonData = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String:Any]

                let allPhotos = jsonData["photos"] as! [String:Any]
                
                let photosArray = allPhotos["photo"] as! [Any]
                
                print("photosArray: \(photosArray)")
                
                for singlePhotoDetail in photosArray {
                    let singlePhotoDetailDictionary = singlePhotoDetail as! [String: Any]
                    let photoURL = singlePhotoDetailDictionary["url_n"] as! String
                    
                    var photoHeight = 0
                    var photoWidth = 0
                    
                    let photoHeightInt = singlePhotoDetailDictionary["height_n"] as? Int
                    let photoHeightString = singlePhotoDetailDictionary["height_n"] as? String
                    
                    if((photoHeightInt) != nil) {
                        photoHeight = photoHeightInt!
                    } else {
                        photoHeight = (photoHeightString! as NSString).integerValue
                    }

                    let photoWidthInt = singlePhotoDetailDictionary["width_n"] as? Int
                    let photoWidthString = singlePhotoDetailDictionary["width_n"] as? String
                    
                    if((photoWidthInt) != nil) {
                        photoWidth = photoWidthInt!
                    } else {
                        photoWidth = (photoWidthString! as NSString).integerValue
                    }
                    let photoDetailObject = PhotoInfo(photoURL: photoURL, photoHeight: photoHeight, photoWidth: photoWidth);
                    self.allPhotoInfo.append(photoDetailObject)
                }
                print("Total Photos: \(self.allPhotoInfo.count)")
                
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
