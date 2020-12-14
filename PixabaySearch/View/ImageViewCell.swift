//
//  ImageViewCell.swift
//  PixabaySearch
//
//  Created by Anfisa Klisho on 14.12.2020.
//

import UIKit

class ImageViewCell: UICollectionViewCell {
    static let identifier = "Cell"
   
    
    @IBOutlet private weak var imageView: UIImageView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
    
    func configure(with image: UIImage?){
        imageView.image = image
        
    }
}
