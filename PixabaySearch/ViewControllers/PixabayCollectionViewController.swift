//
//  PixabayCollectionViewController.swift
//  PixabaySearch
//
//  Created by Anfisa Klisho on 09.12.2020.
//

import UIKit



class PixabayCollectionViewController: UICollectionViewController {
    
    private let activityIndicator = UIActivityIndicatorView()
    private var currentQuery = ""

    private var images: [UIImage?] = []
    private var imagesInfo = [ImageInfo]()
    private var page = 1
    private var fetchMore = false
    
    private let detailVCSegueIdentifier = "ShowPhotoDetails"
    
    
    
    //MARK:-Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        
        getCachedImages()
        //loadImages()

    }
    
    //MARK:-Configure
    private func configure(){
        collectionView.collectionViewLayout = CompositionalLayout.createLayout()
        setupSearchController()
        setupActivityIndicator(for: activityIndicator)
        
    }
    
   
    
    //MARK:-Search Controller Configure
    private func setupSearchController(){
        let searchC = UISearchController(searchResultsController: nil)
        searchC.searchBar.placeholder = "Search"
        searchC.searchBar.returnKeyType = .search
        searchC.searchBar.delegate = self
        searchC.obscuresBackgroundDuringPresentation = false
        searchC.searchBar.autocorrectionType = .yes
        navigationItem.searchController = searchC
        
    }
    
    

    //MARK:-Load Images
    private func loadImages(query: String){
        if !fetchMore{
            imagesInfo.removeAll()
            images.removeAll()
            updateUI()
        }
        
        self.fetchMore = false
        activityIndicator.startAnimating()
        
        NetworkService.shared.fetchImages(query: query, amount: 60, page: page) { (result) in
            self.activityIndicator.stopAnimating()
            switch result{
            case let .failure(error):
                print(error)
                self.showAlert(title: error.localizedDescription)
            
            case let .success(imagesInfo):
                self.imagesInfo += imagesInfo
                self.images += Array(repeating: nil, count: imagesInfo.count)
                self.fetchMore = true
                self.updateUI()
            
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
        NetworkService.shared.loadImage(from: info.webformatURL, with: info.id) { (image) in
            if index < self.images.count{
                self.images[index] = image
                CacheManager.shared.cacheImage(image, with: info.id)
                cell.configure(with: self.images[index])
            }
        }
    
    }
    
    
    //MARK:-Get Cached Images
    private func getCachedImages(){
        CacheManager.shared.getCachedImages { (images) in
            self.images = images
            self.updateUI()

        }
    }
    
    
    
    //MARK:-Infinite Scroll Implementation
    ///Maximal number of page is 9 for number of pictures per page equal to 60
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height

        if offsetY > contentHeight - scrollView.frame.height {
            if fetchMore && page < 9{
                page += 1
                loadImages(query: currentQuery)
                
            }
        }}
    
    //MARK:-Load Header
    func loadHeader(for header: SearchHeaderView){
        if images.count == 0{
            header.configure(with: "")
        }
        else if currentQuery.count == 0{
            header.configure(with: "Last searched: ")
        }
        else{
            header.configure(with: "Search results for: '\(currentQuery)'")
        }
        
    }
    


    // MARK: UICollectionViewDataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageViewCell.searchIdentifier, for: indexPath) as? ImageViewCell else{
            fatalError("Invalid cell type")
        }
        
        loadImage(for: cell, at: indexPath.row)
        
    
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let reusableView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SearchHeaderView.identifier, for: indexPath) as? SearchHeaderView else{
            fatalError("Invalid reusable view kind")
        }
        
        loadHeader(for: reusableView)
        
        return reusableView

    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        collectionView.deselectItem(at: indexPath, animated: true)
        if imagesInfo.count > 0{
            performSegue(withIdentifier: detailVCSegueIdentifier, sender: imagesInfo[indexPath.row])
        }
    }
    
    
    
    //MARK:-Prepare for segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == detailVCSegueIdentifier{
            guard let pictureDetailsVC = segue.destination as? PictureDetailsViewController,
                  let imageInfo = sender as? ImageInfo
            else{
                return
            }
            pictureDetailsVC.imageInfo = imageInfo
        }
    }
    

}
   

//MARK:-Implementation of searching of images
extension PixabayCollectionViewController: UISearchBarDelegate{
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let query = searchBar.text, query.count >= 3 else{
            return}
        currentQuery = query
        self.fetchMore = false
        loadImages(query: currentQuery)
        
        
    }
}


    
    

