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
        configure()
        //loadImages()
        //getCachedImages()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

    }
    
    private func configure(){
        collectionView.collectionViewLayout = PixabayCollectionViewController.createLayout()
        
        setupSearchController()
    }
    
    private func setupSearchController(){
        let searchC = UISearchController(searchResultsController: nil)
        searchC.searchBar.placeholder = "Search"
        searchC.searchBar.returnKeyType = .search
        //searchC.searchResultsUpdater = self
        searchC.searchBar.delegate = self
        navigationItem.searchController = searchC
        
    }

    //MARK:-Load Images
    private func loadImages(query: String){
        self.fetchMore = false
        imagesInfo.removeAll()
        images.removeAll()
        NetworkService.shared.fetchImages(query: query, amount: 200, page: page) { (result) in
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
        if let image = images[index]{
            cell.configure(with: image)
            return
        }
        let info = imagesInfo[index]
        NetworkService.shared.loadImage(from: info.webformatURL) { (image) in
            if index < self.images.count{
                self.images[index] = image
                //CacheManager.shared.cacheImage(image, with: info.id)
                cell.configure(with: self.images[index])
            }
        }
        
    }
    
    
    private func getCachedImages(){
        CacheManager.shared.getCachedImages { (images) in
            self.images = images
            self.collectionView.reloadData()
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
                //loadImages()
                
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

}


//MARK:-SearchResultsUpdating
//extension PixabayCollectionViewController: UISearchResultsUpdating{
//    func updateSearchResults(for searchController: UISearchController) {
//        guard let query = searchController.searchBar.text, query.count >= 3 else{
//            return
//        }
//        //searchController.searchBar.pressesEnded(<#T##presses: Set<UIPress>##Set<UIPress>#>, with: <#T##UIPressesEvent?#>)
//        loadImages(query: query)
//    }
//
//
//}
extension PixabayCollectionViewController: UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let query = searchBar.text, query.count >= 3 else{
            return}
        
        loadImages(query: query)
    }
}


    
    

