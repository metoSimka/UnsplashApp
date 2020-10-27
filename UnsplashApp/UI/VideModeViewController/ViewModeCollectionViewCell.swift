//
//  ViewModeCollectionViewCell.swift
//  UnsplashApp
//
//  Created by metoSimka on 24.10.2020.
//  Copyright © 2020 metoSimka. All rights reserved.
//

import UIKit

class ViewModeCollectionViewCell: ImageCollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    var imageModel: ImageURLs?
    
    private var lowImage: UIImage?
    private var highImage: UIImage?
    private var dataTask: URLSessionDataTask?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        updateImageView(lowImage: lowImage, highImage: highImage)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.imageView.image = nil
        lowImage = nil
        highImage = nil
        spinner.startAnimating()
        stopTask()
    }
    
    // MARK: - IBActions
    
    // MARK: - Public methods
    public func setup(_ imageModel: ImageURLs) {
        self.imageModel = imageModel
        self.dataTask = RequestService.shared.loadImage(urlString: imageModel.thumb) { result in
            guard let image = result else {
                return
            }
            self.lowImage = image
            self.updateImageView(lowImage: self.lowImage, highImage: self.highImage)
            self.stopTask()
            self.dataTask = RequestService.shared.loadImage(urlString: imageModel.regular, completion: { (image) in
                self.highImage = image
                self.updateImageView(lowImage: self.lowImage, highImage: self.highImage)
                self.stopTask()
            })
        }
    }
    
    // MARK: - Private methods
    private func stopTask() {
        self.dataTask?.cancel()
        self.dataTask = nil
    }
    
    private func updateImageView(lowImage: UIImage?, highImage: UIImage?) {
        if let highImage = highImage {
            spinner.stopAnimating()
            self.imageView.image = highImage
        } else if let lowQImage = lowImage {
            spinner.stopAnimating()
            self.imageView.image = lowQImage
        } else {
            self.imageView.image = nil
            spinner.startAnimating()
        }
    }
}
