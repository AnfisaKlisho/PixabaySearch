//
//  PixabayCollectionViewController.swift
//  PixabaySearch
//
//  Created by Anfisa Klisho on 09.12.2020.
//

import UIKit



class PixabayCollectionViewController: UICollectionViewController {
    
    private var activityIndicator = UIActivityIndicatorView()
    
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
        
        //getCachedImages()
        //loadImages()

    }
    
    private func configure(){
        collectionView.collectionViewLayout = CompositionalLayout.createLayout()
        setupSearchController()
        setupActivityIndicator()
        
    }
    
    //MARK:-Setup Spinner
    private func setupActivityIndicator(){
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = .large
        activityIndicator.frame = collectionView.bounds
        activityIndicator.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.addSubview(activityIndicator)
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
    
    //MARK:-Update UI
    private func updateUI(){
        UIView.transition(with: collectionView, duration: 0.5, options: .transitionCrossDissolve, animations: {
                    self.collectionView.reloadData()
                }, completion: nil)
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
        
        NetworkService.shared.fetchImages(query: query, amount: 200, page: page) { (result) in
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
        NetworkService.shared.loadImage(from: info.webformatURL) { (image) in
            if index < self.images.count{
                self.images[index] = image
                CacheManager.shared.cacheImage(image, with: info.id)
                cell.configure(with: self.images[index])
            }
        }
        
    }
    
    
    private func getCachedImages(){
        CacheManager.shared.getCachedImages { (images) in
            self.images = images
            self.updateUI()

        }
    }
    
    //MARK:-Show Alert
    private func showAlert(title: String){
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        
       present(alert, animated: true, completion: nil)
    }
    
    
    //MARK:-Infinite Scroll Implementation
    ///Maximal number of page is 3
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height

        if offsetY > contentHeight - scrollView.frame.height {
            if fetchMore && page < 3{
                page += 1
                loadImages(query: currentQuery)
                
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
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        collectionView.deselectItem(at: indexPath, animated: true)
        performSegue(withIdentifier: detailVCSegueIdentifier, sender: imagesInfo[indexPath.row + indexPath.section * 12])
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


    
    

