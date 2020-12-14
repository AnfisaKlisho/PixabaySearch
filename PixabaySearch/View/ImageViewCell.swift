//
//  ImageViewCell.swift
//  PixabaySearch
//
//  Created by Anfisa Klisho on 14.12.2020.
//

import UIKit

class ImageViewCell: UICollectionViewCell {
    static let identifier = "Cell"
   
    
    @IBOutlet weak var imageView: UIImageView!
    
    func configure(with image: UIImage?){
        imageView.image = image
        
    }
}
