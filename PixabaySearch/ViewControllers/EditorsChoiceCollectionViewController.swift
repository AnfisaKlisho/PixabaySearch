//
//  EditorsChoiceCollectionViewController.swift
//  PixabaySearch
//
//  Created by Anfisa Klisho on 22.12.2020.
//

import UIKit



class EditorsChoiceCollectionViewController: UICollectionViewController {
    
    private let activityIndicator = UIActivityIndicatorView()
    
    private var images: [UIImage?] = []
    private var imagesInfo = [ImageInfo]()
  
    
    private let detailVCSegueIdentifier = "ShowDetailedEditors"
    

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        
    }
    
    private func configure(){
        collectionView.collectionViewLayout = CompositionalLayoutForEditors.createLayout()
        loadImages()
        setupActivityIndicator(for: activityIndicator)
    }
    
    private func loadImages(){
        activityIndicator.startAnimating()
        NetworkService.shared.fetchEditorsImages(amount: 200) { (result) in
            self.activityIndicator.stopAnimating()
            switch result{
            case let .failure(error):
                print(error)
                self.showAlert(title: error.localizedDescription)
            
            case let .success(imagesInfo):
                self.imagesInfo += imagesInfo
                self.images += Array(repeating: nil, count: imagesInfo.count)
                self.updateUI()
        }
        }
    }
    
    
    
    //MARK:-Load Image
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


    // MARK: UICollectionViewDataSource

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageViewCell.editorsIdentifier, for: indexPath) as? ImageViewCell else{
            fatalError("Invalid cell type")
        }
    
        loadImage(for: cell, at: indexPath.row)
    
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        collectionView.deselectItem(at: indexPath, animated: true)
        performSegue(withIdentifier: detailVCSegueIdentifier, sender: imagesInfo[indexPath.row])
        
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





