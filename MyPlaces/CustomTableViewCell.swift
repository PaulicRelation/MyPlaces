//
//  CustomTableViewCell.swift
//  MyPlaces
//
//  Created by Pavel on 6/8/19.
//  Copyright © 2019 Pavel. All rights reserved.
//

import UIKit

class CustomTableViewCell: UITableViewCell {
    
    @IBOutlet weak var imageOfPlace: UIImageView! {
        didSet{
            imageOfPlace.layer.cornerRadius = imageOfPlace.frame.size.height/2
            imageOfPlace.clipsToBounds = true
        }
    }
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var ratingStarView: RatingControl! {
        didSet { ratingStarView.updateOnTouch = false }
    }

    
}
