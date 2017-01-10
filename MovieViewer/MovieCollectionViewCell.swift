//
//  MovieCollectionViewCell.swift
//  MovieViewer
//
//  Created by Akbar Mirza on 1/8/17.
//  Copyright © 2017 Akbar Mirza. All rights reserved.
//

import UIKit

protocol MovieCollectionViewCellDelegate {
    
}

class MovieCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var overviewLabel: UILabel!
    
    @IBOutlet weak var posterView: UIImageView!
    
    var delegate: MovieCollectionViewCellDelegate? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization Code
        // posterView = UIImageView(frame: contentView.frame)
        // posterView.contentMode = .scaleAspectFill
        // posterView.clipsToBounds = true
        // remember to add UI elements to contentView, not the cell itself
        // contentView.addSubview(posterView)
    }
    
}
