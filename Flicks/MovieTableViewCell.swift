//
//  MovieTableViewCell.swift
//  Flicks
//
//  Created by Mandy Chen on 9/16/17.
//  Copyright © 2017 Mandy Chen. All rights reserved.
//

import UIKit

class MovieTableViewCell: UITableViewCell {

    @IBOutlet weak var posterImage: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var overview: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        overview.lineBreakMode = .byWordWrapping 
        overview.numberOfLines = 0
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
