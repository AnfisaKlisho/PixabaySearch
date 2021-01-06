//
//  PictureDetailsViewController.swift
//  PixabaySearch
//
//  Created by Anfisa Klisho on 16.12.2020.
//

import UIKit

class PictureDetailsViewController: UIViewController, UIPopoverPresentationControllerDelegate {
    
    private let userImageSegueIndentifier = "ShowUserImage"
    
    var imageScrollView: ImageScrollView!
    
    
    @IBOutlet private weak var userImage: UIImageView!
    @IBOutlet private weak var userNameLabel: UILabel!
    
    //@IBOutlet private weak var photoImage: UIImageView!
    
   
    
    @IBOutlet private weak var likesLabel: UILabel!
    @IBOutlet private weak var viewsLabel: UILabel!
    @IBOutlet private weak var commentsLabel: UILabel!
    @IBOutlet private weak var favouritesLabel: UILabel!
    
    var imageInfo: ImageInfo!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageScrollView = ImageScrollView(frame: view.bounds)
        view.addSubview(imageScrollView)
        setupImageScrollView()
        configure()

    }
    
    func setupImageScrollView(){
        imageScrollView.translatesAutoresizingMaskIntoConstraints = false
        imageScrollView.topAnchor.constraint(equalTo: userImage.bottomAnchor, constant: 20).isActive = true
        imageScrollView.bottomAnchor.constraint(equalTo: likesLabel.topAnchor, constant: -20).isActive = true
        imageScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        imageScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        
    }
    
    private func configure(){
        likesLabel.text = stringFromInt(number: imageInfo.likes)
        commentsLabel.text = stringFromInt(number: imageInfo.comments)
        favouritesLabel.text = stringFromInt(number: imageInfo.favorites)
        viewsLabel.text = stringFromInt(number: imageInfo.views)
        userNameLabel.text = imageInfo.user
        userImage.layer.cornerRadius = userImage.frame.size.width / 2
        userImage.clipsToBounds = true
        
        loadPhoto(from: imageInfo.webformatURL, with: imageInfo.id)
        loadUserPhoto(from: imageInfo.userImageURL)
        
        
    }
    
    
    private func stringFromInt(number: Int) -> String{
        if number >= 1000{
            return "\(number / 1000).\(number % 1000 / 100)K"
        }
        else{
            return "\(number)"
        }
    }
    
    private func loadPhoto(from url: URL?, with id: Int){
        NetworkService.shared.loadImage(from: url, with: id) { (image) in
            //self.photoImage.image = image
            self.imageScrollView.set(image: image!)
        }
    }
    
    private func loadUserPhoto(from address: String){
        guard let url = URL(string: address) else{
            userImage.image = UIImage(named: "default-user-image")
            return
        }
        NetworkService.shared.loadImage(from: url, with: 0) { (image) in
            self.userImage.image = image
        }
    }
    
//MARK:-Share Button
    @IBAction func shareButtonClicked(_ sender: Any) {
        let activityVC = UIActivityViewController(activityItems: [imageScrollView.imageZoomView!], applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = self.view
        self.present(activityVC, animated: true, completion: nil)
    }
    
    
}


