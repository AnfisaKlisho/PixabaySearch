//
//  PixabayCollectionViewController.swift
//  PixabaySearch
//
//  Created by Anfisa Klisho on 09.12.2020.
//

import UIKit



class PixabayCollectionViewController: UICollectionViewController {
    

    //private var images: [UIImage?] = []
    private var imagesInfo = [ImageInfo]()
    
    private let spacing: CGFloat = 5
    private let numberOfItemsPerRow: CGFloat = 2
    
   
    //MARK:-Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
      
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
      
        
        loadImages()

        // Do any additional setup after loading the view.
    }

    
    private func loadImages(){
        NetworkService.shared.fetchImages(amount: 30) { (result) in
            switch result{
            case let .failure(error):
                print(error)
                //MARK:-Show Alert
            case let .success(imagesInfo):
                self.imagesInfo = imagesInfo
                //self.images = Array(repeating: nil, count: imagesInfo.count)
                self.collectionView.reloadData()
            
            }
        }
    }
    
    private func loadImage(for cell: ImageViewCell, at index: Int) {
            let info = imagesInfo[index]
            NetworkService.shared.loadImage(from: info.previewURL) { (image) in
                if let image = image{
                cell.configure(with: image)
            }
        }
        
        
    }




    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return imagesInfo.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageViewCell.identifier, for: indexPath) as? ImageViewCell else{
            fatalError("Invalid cell type")
        }
        
        
        loadImage(for: cell, at: indexPath.row)
    
        return cell
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}

extension PixabayCollectionViewController: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = view.bounds.width
        let insets = 2 * spacing
        let rawWidth = width - spacing - insets
        
        let bigCellWidth = rawWidth / 2
        let smallCellHeight = (bigCellWidth - spacing) / 2
        let smallCellWidth = rawWidth / 2
        
        if indexPath.row % 4 == 0 || (indexPath.row - 1) % 4 == 0{
            return CGSize(width: bigCellWidth, height: bigCellWidth)}
        else{
            return CGSize(width: smallCellWidth, height: smallCellHeight)
            }
        }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets(top: spacing,
                     left: spacing,
                     bottom: spacing,
                     right: spacing
        )
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return spacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return spacing
    }
    }


