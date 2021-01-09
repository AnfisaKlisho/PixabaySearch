//
//  ImageScrollView.swift
//  PixabaySearch
//
//  Created by Anfisa Klisho on 06.01.2021.
//

import UIKit

class ImageScrollView: UIScrollView, UIScrollViewDelegate {


    var imageZoomView: UIImageView!

    lazy var zoomingTap: UITapGestureRecognizer = {
        let zoomingTap = UITapGestureRecognizer(target: self, action: #selector(handleZoomingTap))
        zoomingTap.numberOfTapsRequired = 2
        return zoomingTap
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        scrollViewSetup()

    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        scrollViewSetup()

    }
    
    //MARK:-Pinch to Zoom
    func scrollViewSetup(){
        self.delegate = self
        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
        self.decelerationRate = UIScrollView.DecelerationRate.fast
    }

    func set(image: UIImage){
        imageZoomView?.removeFromSuperview()
        imageZoomView = nil
        imageZoomView = UIImageView(image: image)
        self.addSubview(imageZoomView)

        configurateFor(imageSize: image.size)

    }

    func configurateFor(imageSize: CGSize){
        self.contentSize = imageSize

        setCurrentMaxAndMinZoomScale()
        self.zoomScale = self.minimumZoomScale

        self.imageZoomView.addGestureRecognizer(self.zoomingTap)
        self.imageZoomView.isUserInteractionEnabled = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.centerImage()
    }

    func setCurrentMaxAndMinZoomScale(){
        let boundsSize = self.bounds.size
        let imageSize = imageZoomView.bounds.size

        let xScale = boundsSize.width / imageSize.width
        let yScale = boundsSize.height / imageSize.height
        let minScale = min(xScale, yScale)

        var maxScale: CGFloat = 1.0

        switch minScale {
        case ..<0.1:
            maxScale = 0.3
        case 0.1...0.5:
            maxScale = 0.7
        default:
            maxScale = max(1.0, minScale)
        }


        self.minimumZoomScale = minScale
        self.maximumZoomScale = maxScale

    }

    func centerImage(){
        let boundsSize = self.bounds.size
        var frameToCenter = imageZoomView?.frame ?? CGRect.zero

        if frameToCenter.size.width < boundsSize.width{
            frameToCenter.origin.x = (bounds.width - frameToCenter.size.width) / 2
        } else{
            frameToCenter.origin.x = 0
        }

        if frameToCenter.size.height < boundsSize.height{
            frameToCenter.origin.y = (bounds.height - frameToCenter.size.height) / 2
        } else{
            frameToCenter.origin.y = 0
        }

        imageZoomView?.frame = frameToCenter
    }

    //MARK:-Dobble Tap Zoom
    @objc func handleZoomingTap(sender: UITapGestureRecognizer){
        let location = sender.location(in: sender.view)
        self.zoom(point: location, animated: true)

    }

    func zoom(point: CGPoint, animated: Bool){
        let currentScale = self.zoomScale
        let minScale = self.minimumZoomScale
        let maxScale = self.maximumZoomScale

        if (minScale == maxScale && minScale > 1){
            return
        }

        let toScale = maxScale
        let finalScale = (currentScale == minScale) ? toScale : minScale
        let zoomRect = self.zoomRect(scale: finalScale, center: point)
        self.zoom(to: zoomRect, animated: animated)
    }

    func zoomRect(scale: CGFloat, center: CGPoint) -> CGRect{
        var zoomRect = CGRect.zero
        let bounds = self.bounds

        zoomRect.size.width = bounds.size.width / scale
        zoomRect.size.height = bounds.size.height / scale

        zoomRect.origin.x = center.x - (zoomRect.size.width / 2)
        zoomRect.origin.y = center.y - (zoomRect.size.height / 2)

        return zoomRect
    }

    //MARK:- UIScrollViewDelegate
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageZoomView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        self.centerImage()
    }

}
