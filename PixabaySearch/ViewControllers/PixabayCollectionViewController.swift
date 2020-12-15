//
//  PixabayCollectionViewController.swift
//  PixabaySearch
//
//  Created by Anfisa Klisho on 09.12.2020.
//

import UIKit



class PixabayCollectionViewController: UICollectionViewController {
    

    private var images: [UIImage?] = []
    private var imagesInfo = [ImageInfo]()
    private var page = 1
    private var fetchMore = false
    
    
   
    //MARK:-Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.collectionViewLayout = PixabayCollectionViewController.createLayout()
        //collectionView.prefetchDataSource = self
        loadImages()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

    }

    //MARK:-Load Images
    private func loadImages(){
        self.fetchMore = false
        NetworkService.shared.fetchImages(amount: 200, page: page) { (result) in
            switch result{
            case let .failure(error):
                print(error)
                self.showAlert(title: error.localizedDescription)
            
            case let .success(imagesInfo):
                self.imagesInfo += imagesInfo
                self.images += Array(repeating: nil, count: imagesInfo.count)
                self.fetchMore = true
                self.collectionView.reloadData()
            
            }
        }
    }
    
    //MARK:-Load Image to cell
    private func loadImage(for cell: ImageViewCell, at index: Int) {
        let info = imagesInfo[index]
        if let image = images[index]{
            cell.configure(with: image)
            return
        }
        NetworkService.shared.loadImage(from: info.webformatURL) { (image) in
                self.images[index] = image
                cell.configure(with: self.images[index])
            
        }
        
        
    }
    
    //MARK:-Show Alert
    private func showAlert(title: String){
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        
       present(alert, animated: true, completion: nil)
    }
    
    
    //MARK:-Infinite Scroll Implementation
    //Maximal number of page is 3
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height

        if offsetY > contentHeight - scrollView.frame.height {
            if fetchMore && page < 3{
                page += 1
                loadImages()
                
            }
        }}
    


    // MARK: UICollectionViewDataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return imagesInfo.count / 12
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 12
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageViewCell.identifier, for: indexPath) as? ImageViewCell else{
            fatalError("Invalid cell type")
        }
        
        loadImage(for: cell, at: indexPath.row + indexPath.section * 12)
        
    
        return cell
    }

    
    //MARK:-Compositional Layout
    static func createLayout() -> UICollectionViewCompositionalLayout{
        
        let spacing: CGFloat = 2
        //items
        let squareBigItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalWidth(0.5)))
        let horizontalItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(0.5)))
        let smallSquareItemNearHorizontal = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1)))
        let smallSquareItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.25), heightDimension: .fractionalHeight(1)))
        
        squareBigItem.contentInsets = NSDirectionalEdgeInsets(top: spacing, leading: spacing, bottom: spacing, trailing: spacing)
        horizontalItem.contentInsets = NSDirectionalEdgeInsets(top: spacing, leading: spacing, bottom: spacing, trailing: spacing)
        smallSquareItem.contentInsets = NSDirectionalEdgeInsets(top: spacing, leading: spacing, bottom: spacing, trailing: spacing)
        smallSquareItemNearHorizontal.contentInsets = NSDirectionalEdgeInsets(top: spacing, leading: spacing, bottom: spacing, trailing: spacing)

        //groups
        
        let twoSquareItemsGroup = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(0.5)), subitem: smallSquareItemNearHorizontal, count: 2)
        let threeItemsGroup = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalWidth(0.5)), subitems: [
                        horizontalItem,
                        twoSquareItemsGroup])
        
        let bigGroup = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(0.5)), subitems: [squareBigItem, threeItemsGroup])
        
        let reversedBigGroup = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(0.5)), subitems: [threeItemsGroup, squareBigItem])
        
        let fourGroup = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(1/3)), subitem: smallSquareItem, count: 4)
        
        let group = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(4/3)), subitems: [
            bigGroup,
            reversedBigGroup,
            fourGroup,
        ])
        
        let section = NSCollectionLayoutSection(group: group)
        
        return UICollectionViewCompositionalLayout(section: section)
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


    
    

