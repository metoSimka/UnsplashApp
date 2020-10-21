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

    public func withoutImage() {
        spinner.startAnimating()
    }
    
    public func setup(_ imageModel: ImageData) {
        self.imageModel = imageModel
        guard let thumbUrl: URL = URL(string: imageModel.urls.thumb ) else {
            return
        }
        self.dataTask = loadImage(url: thumbUrl) { image in
            self.lowImage = image
            self.updateImageView(lowImage: image, highImage: nil)
            self.stopTask()
        }
    }
    
    private func stopTask() {
        self.dataTask?.cancel()
        self.dataTask = nil
    }
    
    @discardableResult func loadImage(url: URL, completion: @escaping(UIImage?) -> Void) -> URLSessionDataTask? {
        if let imageFromCache = SimpleImageCache.shared.getImage(url: url) {
            completion(imageFromCache)
            return nil
        } else {
            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                do {
                    guard let data = data else {
                        return
                    }
                    guard let image = UIImage(data: data) else {
                        return
                    }
                    DispatchQueue.main.async {
                        SimpleImageCache.shared.saveToCache(url: url, image: image)
                        completion(image)
                    }
                }
            }
            task.resume()
            return task
        }
        return nil
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
