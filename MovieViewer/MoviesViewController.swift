//
//  MoviesViewController.swift
//  MovieViewer
//
//  Created by Akbar Mirza on 1/5/17.
//  Copyright © 2017 Akbar Mirza. All rights reserved.
//

import UIKit
import AFNetworking // for setImageWith Method
import MBProgressHUD // for Progress HUD

class MoviesViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var layout: UICollectionViewFlowLayout!
    
    @IBOutlet weak var errorView: UIView!
    
    var movies: [NSDictionary]?
    
    var filteredMovies: [NSDictionary]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set up our collectionView
        setupCollectionView()
        
        // Initialize a UIRefreshControl
        let refreshControl = UIRefreshControl()
        
        // Bind the action to the refresh control
        refreshControl.addTarget(self, action: #selector(refreshControlAction(refreshControl:)), for: UIControlEvents.valueChanged)
        
        // add the refresh control to the collection view
        collectionView.insertSubview(refreshControl, at: 0)
        
        // setup searchbar delegate
        searchBar.delegate = self
        
        // set filteredMovies to be equal to movies
        if let movies = movies {
            filteredMovies = movies
        }
        
        // load our data into the view
        loadData(refreshControl: refreshControl)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // initializing our collectionview and adding it to the VC's current view
    func setupCollectionView() {
        // setup the collectionView Delegate
        collectionView.delegate = self
        // setup the collectionView Data Source
        collectionView.dataSource = self
        // set the layout minimum spacing to 0
        layout.minimumLineSpacing = 0
        // set the layout minimum interitem spacing to 0
        layout.minimumInteritemSpacing = 0
    }
    
    func loadData(refreshControl: UIRefreshControl?) {
        // Create the URLRequest (request)
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = URL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")!
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        
        // Configure session so that completion handler is executed on main UI thread
        let session = URLSession(
            configuration: URLSessionConfiguration.default,
            delegate: nil,
            delegateQueue: OperationQueue.main
        )
        
        // Show Progress HUD
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        let task: URLSessionDataTask = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            if let data = data {
                if let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    // NOTE: Debug Code
                    // print(dataDictionary)
                    
                    // Hide Network Error Banner
                    self.errorView.isHidden = true
                    
                    // Use the new data to update the data source
                    self.movies = dataDictionary["results"] as? [NSDictionary]
                    
                    // Update filteredData
                    self.filteredMovies = self.movies
                    
                    // Reload the collectionView now that there is new data
                    self.collectionView.reloadData()
                    
                    // if a refreshControl was passed
                    if let refreshControl = refreshControl {
                        // Tell the refreshControl to stop spinning
                        refreshControl.endRefreshing()
                    }
                }
            } else {
                // Show Network Error Banner
                self.errorView.isHidden = false
            }
            // Hide HUD once network request is completed
            MBProgressHUD.hide(for: self.view, animated: true)
        }
        task.resume()
    }
    
    // Makes a network reqquest to get updated data
    // Updates the view with new data
    // Hides the RefreshControl
    func refreshControlAction(refreshControl: UIRefreshControl) {
        loadData(refreshControl: refreshControl)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let cell = sender as! UICollectionViewCell
        let indexPath = collectionView.indexPath(for: cell)
        let movie = movies![indexPath!.row]
        
        // create a variable for our detail view controller
        let detailVC = segue.destination as! DetailViewController
        detailVC.movie = movie
        
        
        print("prepare for segue call")
        
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
    func loadImageFromTMDB(iv: UIImageView, posterPath: String) {
        
        // let baseUrl = "https://image.tmdb.org/t/p/w500"
        
        let baseUrl = "https://image.tmdb.org/t/p/"
        
        let small = "w300"
        
        let large = "w500"
        
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

extension MoviesViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // specifying the number of sections in our collectionView
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    // specifying the number of cells in the given section
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let filteredMovies = filteredMovies {
            return filteredMovies.count
        }
        
        return 0
    }
    
    // use this method to dequeue a cell and set it up
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // initializing the cell and set it up
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MovieCell", for: indexPath) as! MovieCollectionViewCell
        
        // call awakeFromNib() to setup cell
        cell.awakeFromNib()
        
        // return cell
        return cell
    }
    
    // we use this method to populate the data of a given cell
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        // instantiate our cell as a MovieCell
        let movieCell = cell as! MovieCollectionViewCell
        // set the movie
        let movie = filteredMovies![indexPath.row]
        // set the title
        let title = movie["title"] as! String
        movieCell.titleLabel.text = title
        
        // set the overview
        let overview = movie["overview"] as! String
        movieCell.overviewLabel.text = overview

        if let posterPath = movie["poster_path"] as? String {
            loadImageFromTMDB(iv: movieCell.posterView, posterPath: posterPath)
        }    }
    
    // this method sets the size of the cell
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 250)
    }
}

extension MoviesViewController: UISearchBarDelegate {
    // Inspired from Snippet in AppCoda's Beginning iOS 10 Programming
    func filterContent(for searchText: String) {
        // make sure our movies dictionary exists
        if let movies = movies {
            // assign a value to our filteredMovies
            if searchText.isEmpty {
                filteredMovies = movies
            } else {
                filteredMovies = movies.filter({ (movie) -> Bool in
                    // get the title of the movie
                    let title = movie["title"] as! String
                    
                    // NOTE: DEBUG CODE
                    // print(title)
                    
                    // check if it's a match
                    let isMatch = title.localizedCaseInsensitiveContains(searchText)
                    
                    // NOTE: DEBUG CODE
                    // print(isMatch)
                    
                    // return true or false, depending on if it's in the set
                    return isMatch
                })
            }
        }
    }
    
    // This method updates filteredData based on the text in the Search Box
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // when there is no text, filteredData is the same as the original data
        // when user has entered text into the search box
        // use the filter method to iterate over all items in a data array
        // for each item, return true if the item should be included and false if 
        // the item should NOT be included
        
        // filter content
        filterContent(for: searchText)
        
        // reload the data in our view
        collectionView.reloadData()
    }
    
    // this method gets called when the user starts editing search text
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        // show the cancel button in the keyboard
        self.searchBar.showsCancelButton = true
    }
    
    // handle what happens when a user clicks on the cancel button
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        // hide the cancel button
        searchBar.showsCancelButton = false
        // empty the search field
        searchBar.text = ""
        // hide the keyboard (?)
        searchBar.resignFirstResponder()
    }
    
}
