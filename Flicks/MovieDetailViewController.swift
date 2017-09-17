//
//  MovieDetailViewController.swift
//  Flicks
//
//  Created by Mandy Chen on 9/16/17.
//  Copyright © 2017 Mandy Chen. All rights reserved.
//

import UIKit

class MovieDetailViewController: UIViewController {
    
    var movie: NSDictionary!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setPostAsBackgroundImage()
        showMovieDetails()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func setPostAsBackgroundImage() {
        if let posterPath = movie["poster_path"] as? String {
            let posterBaseUrl = "http://image.tmdb.org/t/p/w500"
            let posterUrl = NSURL(string: posterBaseUrl + posterPath)
            if let data = try? Data(contentsOf: posterUrl! as URL) {
                view.backgroundColor = UIColor( patternImage: UIImage(data: data)!)
            }
            
        } else {
            // No poster image. Can either set to nil (no image) or a default movie poster image
            // that you include as an asset
        }

    }
    
    func showMovieDetails() {
        let scrollView = UIScrollView(frame: view.bounds)
        view.addSubview(scrollView)
        
        
        let detailView = UIView(frame: CGRect(x: 30, y: 550, width: 350, height: 150))
        detailView.backgroundColor = UIColor(white:0.2, alpha:0.8)
        scrollView.addSubview(detailView)

        let titleView = UILabel(frame: CGRect(x: 10, y: 20, width: 350, height: 20))
        let title = movie["original_title"] as? String
        let titleAttributes : [String: Any] = [
            NSForegroundColorAttributeName: UIColor.white,
            NSFontAttributeName: UIFont(name: "Helvetica-Bold", size: 14.0)! ]
        titleView.attributedText = NSAttributedString( string: title! , attributes: titleAttributes )
        detailView.addSubview(titleView)
        
        
        let releaseDateView = UILabel(frame: CGRect(x: 10, y: 60, width: 350, height: 15))
        let releaseDate = movie["release_date"] as? String
        let releaseDateAttributes : [String: Any] = [
            NSForegroundColorAttributeName: UIColor.white,
            NSFontAttributeName: UIFont(name: "Helvetica", size: 12.0)! ]
        releaseDateView.attributedText = NSAttributedString( string: releaseDate! , attributes: releaseDateAttributes )
        detailView.addSubview(releaseDateView)

        
        let voteAvgView = UILabel(frame: CGRect(x: 10, y: 80, width: 150, height: 15))
        let voteAvg = String( describing: movie["vote_average"] ?? 0 )
        let voteAvgAttributes : [String: Any] = [
            NSForegroundColorAttributeName: UIColor.white,
            NSFontAttributeName: UIFont(name: "Helvetica", size: 14.0)! ]
        voteAvgView.attributedText = NSAttributedString( string: String(format: "Score: %@", voteAvg) , attributes: voteAvgAttributes )
        detailView.addSubview(voteAvgView)
        
        let overviewView = UILabel(frame: CGRect(x: 10, y: 100, width: 350, height: 80))
        overviewView.lineBreakMode = .byWordWrapping
        overviewView.numberOfLines = 0
        let overview = movie["overview"] as? String
        let overviewAttributes : [String: Any] = [
            NSForegroundColorAttributeName: UIColor.white,
            NSFontAttributeName: UIFont(name: "Helvetica-Bold", size: 14.0)! ]
        overviewView.attributedText = NSAttributedString( string: overview! , attributes: overviewAttributes )
        detailView.addSubview(overviewView)
        
        overviewView.sizeToFit()
        let detailViewHeight = overviewView.frame.origin.y + overviewView.frame.height + 30.0
        detailView.frame = CGRect(x: detailView.frame.origin.x, y: detailView.frame.origin.y, width: detailView.frame.width, height: detailViewHeight )
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width, height: detailView.frame.origin.y + detailView.frame.size.height )
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
