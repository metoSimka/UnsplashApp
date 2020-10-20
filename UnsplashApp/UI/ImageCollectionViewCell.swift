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
    
    private var imageModel: ImageModel?
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    var dataTask: URLSessionDataTask?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        dataTask?.cancel()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    public func setUrls(_ imageModel: ImageModel) {
        self.imageModel = imageModel
        guard let thumbUrl: URL = URL(string: imageModel.urls.thumb ) else {
            return
        }
        guard let fullUrl: URL = URL(string: imageModel.urls.full ) else {
            return
        }
        self.dataTask = loadImage(url: thumbUrl) { image in
            self.lowImage = image
            self.updateImageView(lowImage: image, highImage: nil)
            self.dataTask?.cancel()
            self.dataTask = nil
            self.dataTask = self.loadImage(url: fullUrl, completion: { (image) in
                self.highImage = image
                self.updateImageView(lowImage: self.lowImage, highImage: image)
            })
        }
    }
    
    @discardableResult func loadImage(url: URL, completion: @escaping(UIImage?) -> Void) -> URLSessionDataTask? {
        if let image = ImageLoadManager.manager.cachedImages[url.absoluteString] {
            self.lowImage = image
            return nil
        }
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            do {
                guard let data = data else {
                    return
                }
                let image = UIImage(data: data)
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
    
    private func cacheImage(url: URL, image: UIImage) {
        ImageCache.shared.saveToCache(url: url, image: image)
    }
}
