//
//  MainViewController.swift
//  mezi-flickr-photos
//
//  Created by Lokesh Basu on 21/11/16.
//  Copyright © 2016 mezi-flickr-photos. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    let apiEndpoint = "https://api.flickr.com/services/rest/?method=flickr.interestingness.getList&api_key=d98f34e2210534e37332a2bb0ab18887&format=json&extras=url_n"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Inside Main View Controller")
        
        getImageData();
    }
    
    func getImageData() {
        let session = URLSession(configuration: URLSessionConfiguration.default)
        
        let request = NSURLRequest(url: NSURL(string: self.apiEndpoint)! as URL)
        
        let task: URLSessionDataTask = session.dataTask(with: request as URLRequest) { (data, response, error) -> Void in
            if let data = data {
                let response = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
                print(response ?? String())
            }
        }
        task.resume()
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
