//
//  Extension.swift
//  PixabaySearch
//
//  Created by Anfisa Klisho on 22.12.2020.
//

import UIKit

extension UICollectionViewController{
    
    
    //MARK:-Show Alert
    func showAlert(title: String){
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        
        present(alert, animated: true, completion: nil)
    }
    
    //MARK:-Update UI
    func updateUI(){
        self.collectionView.reloadSections(IndexSet(arrayLiteral: 0))
    }
    
    //MARK:-Setup Spinner
    func setupActivityIndicator(for activityIndicator: UIActivityIndicatorView){
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = .large
        activityIndicator.frame = collectionView.bounds
        activityIndicator.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.addSubview(activityIndicator)
    }
    
    
}
