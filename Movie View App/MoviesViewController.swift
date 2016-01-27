//
//  MoviesViewController.swift
//  Movie View App
//
//  Created by James Bui on 1/6/16.
//  Copyright © 2016 James Bui. All rights reserved.
//

import UIKit
import AFNetworking

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var refreshControl: UIRefreshControl!
    var movies: [NSDictionary]?     //? makes it optional
    var endpoint: String!
    
    var filteredMovies: [NSDictionary]!
    
    //var searchController: UISearchController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "onRefresh", forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)
        
        tableView.dataSource = self
        tableView.delegate = self
        
        searchBar.delegate = self
        
        
        
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string:"https://api.themoviedb.org/3/movie/\(endpoint)?api_key=\(apiKey)")
        let request = NSURLRequest(URL: url!)
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate:nil,
            delegateQueue:NSOperationQueue.mainQueue()
        )
        
        let task : NSURLSessionDataTask = session.dataTaskWithRequest(request,
            completionHandler: { (dataOrNil, response, error) in
                if let data = dataOrNil {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSDictionary {
                            NSLog("response: \(responseDictionary)")
                            self.movies = responseDictionary["results"] as! [NSDictionary]
                            self.filteredMovies = self.movies
                            self.tableView.reloadData()
                            //self.filteredMovies = self.movies
                    }
                }
        });
        task.resume()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Determine the number of rows
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        /*
        if let movies = movies {    // in case our network is not working
            return movies.count
        }
        else {
           return 0
        }*/
        
        if let movies = filteredMovies {
            return filteredMovies.count
        } else {
            return 0
        }
    }
    
    // Set the labels from dictionary
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell
        let movie = filteredMovies![indexPath.row]
        let title = movie["title"] as! String
        let overview = movie["overview"] as! String
        
        let baseUrl = "http://image.tmdb.org/t/p/w500"
        if let posterPath = movie["poster_path"] as? String {
            let imageUrl = NSURL(string: baseUrl + posterPath)
            cell.posterView.setImageWithURL(imageUrl!)
        }
        
        
        //cell.posterView = setImage
        cell.titleLabel.text = title
        cell.overviewLabel.text = overview
        
        
        print("row \(indexPath.row)")
        return cell
    }
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
    // Refresh
    func onRefresh() {
        delay(2, closure: {
            self.refreshControl.endRefreshing()
        })
    }
    
    // Optional feature: Search Bar
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        filteredMovies = searchText.isEmpty ? movies : movies!.filter({(movie: NSDictionary) -> Bool in
            let title = movie["title"] as! String
            return title.rangeOfString(searchText, options: .CaseInsensitiveSearch) != nil
        })
        
        tableView.reloadData()
    }
    
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = true
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.text = ""
        searchBar.resignFirstResponder()
        tableView.reloadData()
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let cell = sender as! UITableViewCell
        let indexPath = tableView.indexPathForCell(cell)
        let movie = movies![indexPath!.row]
        
        let detailViewController = segue.destinationViewController as! DetailViewController
        
        detailViewController.movie = movie 
        
        
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    

}
