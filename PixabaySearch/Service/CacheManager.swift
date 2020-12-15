//
//  CacheManager.swift
//  PixabaySearch
//
//  Created by Anfisa Klisho on 15.12.2020.
//

import UIKit

class CacheManager{
    private init(){}
    
    static let shared = CacheManager()
    
    private let imagesLimit = 200
    
    private let fileManager = FileManager.default
    
    
    //MARK:-Cache Image
    func cacheImage(_ image: UIImage?, with id: Int, completion: ((Bool) -> Void)? = nil){
        guard let image = image,
              let data = image.pngData() else{
            completion?(false)
            return
        }
        
        
        let imageUrl = getCachedDirectory().appendingPathComponent("\(id).png")
        
        guard !fileManager.fileExists(atPath: imageUrl.path) else {
            completion?(true)
            return
        }
        
        var savedPaths = getCachedImagePaths()
        while savedPaths.count >= imagesLimit{
            
            _ = tryDeleteImages(path: savedPaths.first!)
            savedPaths.remove(at: savedPaths.startIndex)
        }
        
        do{
            try data.write(to: imageUrl)
            print("Image was saved to: \(imageUrl)")
            completion?(true)
        }
        
        catch  {
            print(error)
            completion?(false)
        }
    }
    
    //MARK:-Get Image
    func getImage(with id: Int, completion: (UIImage?) ->Void){
        let imageUrl = getCachedDirectory().appendingPathComponent("\(id)")
        
        let image = getImage(from: imageUrl.path)
        completion(image)
    }
    
    func getImage(from path: String) -> UIImage?{
        if let data = fileManager.contents(atPath: path),
           let image = UIImage(data: data){
            return image
        }
        return nil
        
    }
    
    //MARK:-Get a list of images
    func getCachedImages(completion: ([UIImage])-> Void){
        var images = [UIImage]()
        let imagePaths = getCachedImagePaths()
        for path in imagePaths{
            if let image = getImage(from: path){
                images.append(image)
                }
            
        }
        completion(images)
    }
    
    
    //MARK:-Delete Image
    func tryDeleteImages(id: Int) ->Bool{
        let imageUrl = getCachedDirectory().appendingPathComponent("\(id)")
        return tryDeleteImages(path: imageUrl.path)
    }
    
    func tryDeleteImages(path: String) ->Bool{
        do{
            try fileManager.removeItem(atPath: path)
            return true
        }
        catch{
            return false
        }
    }
    
    private func getCachedImagePaths()->[String]{
        do{
            let paths = try fileManager.contentsOfDirectory(atPath: getCachedDirectory().path)
            return paths.map{getCachedDirectory().appendingPathComponent($0).path}
        }
        catch{
            return []
        }
    }
    
    private func getCachedDirectory() -> URL{
        let url = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        if !fileManager.fileExists(atPath: url.path){
            try! fileManager.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        }
        return url
    
    }
}

