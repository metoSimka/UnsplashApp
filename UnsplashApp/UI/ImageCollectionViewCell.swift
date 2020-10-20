//
//  ImageCollectionViewCell.swift
//  UnsplashApp
//
//  Created by metoSimka on 19.10.2020.
//  Copyright © 2020 metoSimka. All rights reserved.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {

    private var lowImage: UIImage?
    private var highImage: UIImage?
    
    private var imageModel: ImageData?
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    var dataTask: URLSessionDataTask?
    
    let imageCache = NSCache<AnyObject, AnyObject>()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        spinner.startAnimating()
        stopTask()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        updateImageView(lowImage: lowImage, highImage: highImage)
    }
    
    public func setImage(_ image: UIImage?) {
        guard let newImage = image else {
            spinner.startAnimating()
            return
        }
        spinner.stopAnimating()
        self.imageView.image = image
        
    }
    
    public func withoutImage() {
        spinner.startAnimating()
    }
    
    public func setUrls(_ imageModel: ImageData) {
        self.imageModel = imageModel
        guard let thumbUrl: URL = URL(string: imageModel.urls.thumb ) else {
            return
        }
//        guard let fullUrl: URL = URL(string: imageModel.urls.full ) else {
//            return
//        }
        
        self.dataTask = loadImage(url: thumbUrl) { image in
            self.lowImage = image
            self.updateImageView(lowImage: image, highImage: nil)
            self.stopTask()
//            self.dataTask = self.loadImage(url: fullUrl, completion: { (image) in
//                self.stopTask()
//                self.highImage = image
//                self.updateImageView(lowImage: self.lowImage, highImage: image)
//            })
        }
    }
    
    private func stopTask() {
        self.dataTask?.cancel()
        self.dataTask = nil
    }
    
    @discardableResult func loadImage(url: URL, completion: @escaping(UIImage?) -> Void) -> URLSessionDataTask? {
//        if let imageFromCache = imageCache.object(forKey: url.absoluteString as AnyObject) as? UIImage {
//            completion(imageFromCache)
//            return nil
//        }
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            do {
                guard let data = data else {
                    return
                }
                guard let image = UIImage(data: data) else {
                    return
                }
//                self.imageCache.setObject(image, forKey: url.absoluteString as AnyObject)
                DispatchQueue.main.async {
                    completion(image)
                }
            }
        }
        task.resume()
        return task
    }

    private func updateImageView(lowImage: UIImage?, highImage: UIImage?) {
        if let highQImage = highImage {
            spinner.stopAnimating()
            self.imageView.image = highQImage
        } else if let lowQImage = lowImage {
            spinner.stopAnimating()
            self.imageView.image = lowQImage
        } else {
            spinner.startAnimating()
        }
    }
}
