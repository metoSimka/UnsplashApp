//
//  ImageCollectionViewCell.swift
//  UnsplashApp
//
//  Created by metoSimka on 19.10.2020.
//  Copyright © 2020 metoSimka. All rights reserved.
//

import UIKit

// MARK: - Protocol Conformance
class ImageCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Public constants
    
    // MARK: - Public variables

    // MARK: - IBOutlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    // MARK: - Private constants
    
    // MARK: - Private variables
    private var lowImage: UIImage?
    private var highImage: UIImage?
    private var dataTask: URLSessionDataTask?
    
    private var imageModel: ImageURLs?
    
    // MARK: - Lifecycle
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        spinner.startAnimating()
        stopTask()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        updateImageView(lowImage: lowImage)
    }
        
    // MARK: - IBActions
    
    // MARK: - Public methods
    public func setup(_ imageModel: ImageURLs) {
        self.imageModel = imageModel
        guard let thumbUrl: URL = URL(string: imageModel.thumb ) else {
            return
        }
        let requestService = RequestService()
        self.dataTask = requestService.loadImage(url: thumbUrl) { image in
            self.lowImage = image
            self.updateImageView(lowImage: image)
            self.stopTask()
        }
    }
    
    // MARK: - Private methods
    private func stopTask() {
        self.dataTask?.cancel()
        self.dataTask = nil
    }
    

    private func updateImageView(lowImage: UIImage?) {
        if let lowQImage = lowImage {
            spinner.stopAnimating()
            self.imageView.image = lowQImage
        } else {
            self.imageView.image = nil
            spinner.startAnimating()
        }
    }
}
