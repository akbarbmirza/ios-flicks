//
//  DetailViewController.swift
//  MovieViewer
//
//  Created by Akbar Mirza on 1/12/17.
//  Copyright © 2017 Akbar Mirza. All rights reserved.
//

import UIKit
import AFNetworking // for setImageWith Method

class DetailViewController: UIViewController {
    
    // Set up Outlets for Detail View
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    
    var movie: NSDictionary!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let title = movie["title"] as? String
        titleLabel.text = title
        
        let overview = movie["overview"] as? String
        overviewLabel.text = overview
        
        // run sizeToFit Method
        overviewLabel.sizeToFit()
        infoView.frame.size = CGSize(width: scrollView.frame.size.width, height: titleLabel.frame.height + overviewLabel.frame.height)
        
        // set the size of our scroll view
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width, height: infoView.frame.origin.y + infoView.frame.size.height)
        
        if let posterPath = movie["poster_path"] as? String {
            loadPosterFromTMDB(iv: posterImageView, posterPath: posterPath)
        }
        
        // NOTE: DEBUG CODE
        // print(movie)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func loadPosterFromTMDB(iv: UIImageView, posterPath: String) {
        
        // let baseUrl = "https://image.tmdb.org/t/p/w500"
        
        let baseUrl = "https://image.tmdb.org/t/p/"
        
        let small = "w45"
        
        let large = "original"
        
        let smallImageUrl = URL(string: baseUrl + small + posterPath)
        
        let largeImageUrl = URL(string: baseUrl + large + posterPath)
        
        let smallImageRequest = URLRequest(url: smallImageUrl!)
        let largeImageRequest = URLRequest(url: largeImageUrl!)
        
        iv.setImageWith(
            smallImageRequest,
            placeholderImage: nil,
            success: { (smallImageRequest, smallImageResponse, smallImage) -> Void in
                
                // imageResponse will be nil if the image is cached
                if smallImageResponse != nil {
                    print("Image was NOT cached, fade in image")
                    
                    // set full transparency
                    iv.alpha = 0.0
                    
                    // set the image
                    iv.image = smallImage
                    
                    UIView.animate(withDuration: 0.3, animations: { () -> Void in
                        
                        // set no transparency over a small interval of time
                        iv.alpha = 1.0
                        
                    }, completion: { (success) -> Void in
                        
                        // The AFNetworking ImageView Category only allows one request to be sent at a time
                        // per ImageView. This code must be in the completion block.
                        iv.setImageWith(
                            largeImageRequest,
                            placeholderImage: smallImage,
                            success: { (largeImageRequest, largeImageResponse, largeImage) -> Void in
                                
                                iv.image = largeImage
                                
                        },
                            failure: { (request, response, error) -> Void in
                                // do something for the failure condition of the large image request
                                // possible setting the ImageView's image to a default image
                        })
                        
                    })
                    
                } else {
                    print("Image was cached so just update the image")
                    iv.setImageWith(largeImageUrl!)
                    
                }
        },
            failure: { (imageRequest, imageResponse, error) -> Void in
                // do something for the failure condition
                // possibly try to get the large image
        })
        
    }

}
