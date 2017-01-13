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
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                // animate selection
                self.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            } else {
                // animate deselection
                self.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            }
        }
    }
    
}
