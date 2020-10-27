//
//  ViewModeCollectionViewCell.swift
//  UnsplashApp
//
//  Created by metoSimka on 24.10.2020.
//  Copyright © 2020 metoSimka. All rights reserved.
//

import UIKit

class DetailViewModeCollectionViewCell: ImageCollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    var imageModel: DetailImageModel?
    
    private var dataTask: URLSessionDataTask?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        updateImageView(imageModel)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.imageModel = nil
        self.imageView.image = nil
        spinner.startAnimating()
        stopTask()
    }
    
    // MARK: - IBActions
    
    // MARK: - Public methods
    public func setup(_ imageModel: DetailImageModel) {
        self.imageModel = imageModel
        self.updateImageView(self.imageModel)
        if imageModel.thumbImage == nil {
            self.loadImage(url: imageModel.imageURLs?.thumb) { (thumbImage) in
                self.imageModel?.thumbImage = thumbImage
                self.updateImageView(self.imageModel)
                if imageModel.qualityImage == nil {
                    self.loadImage(url: imageModel.imageURLs?.regular) { (qualityImage) in
                        self.imageModel?.qualityImage = qualityImage
                        self.updateImageView(self.imageModel)
                    }
                }
            }
        } else if imageModel.qualityImage == nil {
            self.loadImage(url: imageModel.imageURLs?.regular) { (qualityImage) in
                self.imageModel?.qualityImage = qualityImage
                self.updateImageView(self.imageModel)
            }
        }
    }
    
    private func loadImage(url: String?, completion: @escaping(UIImage?) -> Void) {
        guard let url = url else {
            completion(nil)
            return
        }
        self.dataTask = RequestService.shared.loadImage(urlString: url) { result in
            guard let image = result else {
                return
            }
            self.stopTask()
            completion(image)
        }
    }
    
    // MARK: - Private methods
    private func stopTask() {
        self.dataTask?.cancel()
        self.dataTask = nil
    }
    
    private func updateImageView(_ imageModel: DetailImageModel?) {
        if let highImage = imageModel?.qualityImage {
            spinner.stopAnimating()
            self.imageView.image = highImage
        } else if let thumbImage = imageModel?.thumbImage {
            spinner.stopAnimating()
            self.imageView.image = thumbImage
        } else {
            self.imageView.image = nil
            spinner.startAnimating()
        }
    }
}
