//
//  MovieViewController.swift
//  Flicks
//
//  Created by Mandy Chen on 9/16/17.
//  Copyright © 2017 Mandy Chen. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD

class MovieViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, UISearchResultsUpdating {

    @IBOutlet weak var movieTableView: UITableView!
    
    var movies: [NSDictionary] = []
    var moviesAfterSearch: [NSDictionary]!
    
    var endpoint : String?
    
    var errorAlertView: UIView!
    var isMoreDataLoading = false
    var loadingMoreView:InfiniteScrollActivityView?
    var searchController: UISearchController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        movieTableView.delegate = self
        movieTableView.dataSource = self
        movieTableView.rowHeight = 180;
        
        initSearchBar()
        initErrorView()
        initRefreshControl()
        initInfiniteScroll()
        
        fetchData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Fetch data
    func fetchData() {
        let url = URL(string:"https://api.themoviedb.org/3/movie/\(endpoint!)?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed")
        var request = URLRequest(url: url!)
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        let session = URLSession(
            configuration: URLSessionConfiguration.default,
            delegate:nil,
            delegateQueue:OperationQueue.main
        )
        
        // Display HUD right before the request is made
        showHud()
        
        let task : URLSessionDataTask = session.dataTask(with: request, completionHandler:
            { (dataOrNil, response, error) in
                // Hide HUD once the network request comes back (must be done on main UI thread)
                self.hideHud()
                if let data = dataOrNil {
                    self.errorAlertView.isHidden = true
                    if let dictionary = try! JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                        self.movies = dictionary["results"] as! [NSDictionary]
                        self.movieTableView.reloadData()
                    }
                } else {
                    self.errorAlertView.isHidden = false
                }
        });
        task.resume()
    }
    
    
    // MARK: - Table View
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
            return moviesAfterSearch.count
        } else {
            return movies.count
        }

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieTableViewCell") as! MovieTableViewCell
        
        let movie = getMovie(index: indexPath.section)
        
        if let posterPath = movie["poster_path"] as? String {
            let posterBaseUrl = "http://image.tmdb.org/t/p/w500"
            let posterUrl = NSURL(string: posterBaseUrl + posterPath)
            let imageRequest = NSURLRequest(url: posterUrl as! URL)

            // MARK: - Image fade in
             cell.posterImage.setImageWith(
                imageRequest as URLRequest,
                placeholderImage: nil,
                success: { (imageRequest, imageResponse, image) -> Void in
                    
                    // imageResponse will be nil if the image is cached
                    if imageResponse != nil {
                        cell.posterImage.alpha = 0.0
                        cell.posterImage.image = image
                        UIView.animate(withDuration: 0.3, animations: { () -> Void in
                            cell.posterImage.alpha = 1.0
                        })
                    } else {
                        cell.posterImage.image = image
                    }
            },
                failure: { (imageRequest, imageResponse, error) -> Void in
                    // do something for the failure condition
            })
            
        } else {
            // No poster image. Can either set to nil (no image) or a default movie poster image
            // that you include as an asset
            cell.posterImage.image = nil
        }
        
        if let original_title = movie["original_title"] as? String {
            cell.title.text = original_title
        } else {
            // no title
            cell.title.text = nil
        }
        
        if let overview = movie["overview"] as? String {
            cell.overview.text = overview
        } else {
            // no overview.
        }
        
        // Use a red color when the user selects the cell
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor(red:0.93, green:0.71, blue:0.01, alpha:1.0)
        cell.selectedBackgroundView = backgroundView
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - HUD
    func showHud() {
        // Display HUD right before the request is made
        MBProgressHUD.showAdded(to: self.view, animated: true)
    }
    
    func hideHud() {
        // Hide HUD once the network request comes back (must be done on main UI thread)
        MBProgressHUD.hide(for: self.view, animated: true)
    }
    
    
    // MARK: - ErrorView
    func initErrorView() {
        let errorView = UIView(frame: CGRect(x: 0, y: 0, width: movieTableView.frame.size.width, height: 50))
        errorView.backgroundColor = UIColor.darkGray
        
        let errorLabel = UILabel(frame: CGRect(x: 0, y: 0, width: errorView.frame.size.width, height: errorView.frame.size.height))
        let errorLabelAttributes : [String: Any] = [
            NSForegroundColorAttributeName: UIColor.white,
            NSFontAttributeName: UIFont(name: "Helvetica-Bold", size: 16.0)! ]
        errorLabel.attributedText = NSAttributedString( string: "Network Error" , attributes: errorLabelAttributes )
        errorLabel.textAlignment = .center
        
        errorView.addSubview(errorLabel)
        errorAlertView = errorView
        errorAlertView.isHidden = true
        movieTableView.addSubview(errorAlertView)
    }
    
    // MARK: - Pull and Refresh
    func initRefreshControl() {
        // Initialize a UIRefreshControl
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), for: UIControlEvents.valueChanged)
        // add refresh control to table view
        movieTableView.insertSubview(refreshControl, at: 0)
    }
    
    // Makes a network request to get updated data
    // Updates the tableView with the new data
    // Hides the RefreshControl
    func refreshControlAction(_ refreshControl: UIRefreshControl) {
        
        // ... Create the URLRequest `myRequest` ...
        let url = URL(string:"https://api.themoviedb.org/3/movie/\(endpoint!)?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed")
        var request = URLRequest(url: url!)
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        
        // Configure session so that completion handler is executed on main UI thread
        let session = URLSession(
            configuration: URLSessionConfiguration.default,
            delegate:nil,
            delegateQueue:OperationQueue.main
        )
        
   
        let task : URLSessionDataTask = session.dataTask(with: request, completionHandler:
            { (dataOrNil, response, error) in
                if let data = dataOrNil {
                    self.errorAlertView.isHidden = true
                    if let dictionary = try! JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                        self.movies = dictionary["results"] as! [NSDictionary]
                        self.movieTableView.reloadData()
                        // Tell the refreshControl to stop spinning
                        refreshControl.endRefreshing()
                    }
                } else {
                    self.errorAlertView.isHidden = false
                }
        });
        task.resume()
    }
    
    
    // MARK: - Infinite Scrolling
    func initInfiniteScroll() {
        // Set up Infinite Scroll loading indicator
        let frame = CGRect(x: 0, y: movieTableView.contentSize.height, width: movieTableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
        loadingMoreView = InfiniteScrollActivityView(frame: frame)
        loadingMoreView!.isHidden = true
        movieTableView.addSubview(loadingMoreView!)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Handle scroll behavior here
        
        //When a user scrolls down, the UIScrollView continuously fires scrollViewDidScroll after the UIScrollView has changed. This means that whatever code is inside scrollViewDidScroll will repeatedly fire. In order to avoid 10s or 100s of requests to the server, we need to indicate when the app has already made a request to the server.
        
        if (!isMoreDataLoading) {
            // Calculate the position of one screen length before the bottom of the results
            let scrollViewContentHeight = movieTableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - movieTableView.bounds.size.height
            
            // When the user has scrolled past the threshold, start requesting
            if(scrollView.contentOffset.y > scrollOffsetThreshold && movieTableView.isDragging) {
                isMoreDataLoading = true
                
                // Update position of loadingMoreView, and start loading indicator
                let frame = CGRect(x: 0, y: movieTableView.contentSize.height, width: movieTableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
                loadingMoreView?.frame = frame
                loadingMoreView!.startAnimating()
                
                // ... Code to load more results ...
                loadMoreData()
            }
            
        }
    }
    
    //TODO: Refactor this function and FetchData() to avoid duplicate codes
    func loadMoreData() {
            
        // ... Create the URLRequest `myRequest` ...
        let url = URL(string:"https://api.themoviedb.org/3/movie/\(endpoint!)?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed")
        var request = URLRequest(url: url!)
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        
        // Configure session so that completion handler is executed on main UI thread
        let session = URLSession(
            configuration: URLSessionConfiguration.default,
            delegate:nil,
            delegateQueue:OperationQueue.main
        )
        
        
        let task : URLSessionDataTask = session.dataTask(with: request, completionHandler:
            { (dataOrNil, response, error) in
                // Update flag
                self.isMoreDataLoading = false
                
                // Stop the loading indicator
                self.loadingMoreView!.stopAnimating()
                
                if let data = dataOrNil {
                    self.errorAlertView.isHidden = true
                    if let dictionary = try! JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                        self.movies = dictionary["results"] as! [NSDictionary]
                        self.movieTableView.reloadData()
                    }
                } else {
                    self.errorAlertView.isHidden = false
                }
        });
        task.resume()
    }
        
    
    
    // MARK: - Search
    func initSearchBar() {
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        
        searchController.searchBar.sizeToFit()
        navigationItem.titleView = searchController.searchBar
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        if let keywords = searchController.searchBar.text {
            moviesAfterSearch = keywords.isEmpty ? movies : movies.filter({ (movie) -> Bool in
                if let title = movie["title"] as? String {
                    return title.range(of: keywords, options: .caseInsensitive) != nil
                }
                return false
            })
            movieTableView.reloadData()
        }
    }
    
    func getMovie(index: Int) -> NSDictionary {
        var movie: NSDictionary!
        if searchController.isActive && searchController.searchBar.text != "" {
            movie = moviesAfterSearch[index]
        } else {
            movie = movies[index]
        }
        return movie
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let vc = segue.destination as! MovieDetailViewController
        let cell = sender as! UITableViewCell;
        if let indexPath = movieTableView.indexPath(for: cell){
            vc.movie = getMovie(index: indexPath.section)
        }
    }


}
