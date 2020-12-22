//
//  SearchHeaderView.swift
//  PixabaySearch
//
//  Created by Anfisa Klisho on 22.12.2020.
//

import UIKit

class SearchHeaderView: UICollectionReusableView {
    
    static let identifier = "SearchResult"
    
        
    @IBOutlet private weak var resultLabel: UILabel!
    
    func configure(with text: String){
        resultLabel.text = text
    }
    
}
