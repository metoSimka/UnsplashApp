//
//  SearchImageCollectionViewCell.swift
//  UnsplashApp
//
//  Created by metoSimka on 19.10.2020.
//  Copyright © 2020 metoSimka. All rights reserved.
//

import UIKit

class SearchImageCollectionViewCell: ImageCollectionViewCell {
    
    // MARK: - Public variables

    // MARK: - IBOutlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var selectionMask: UIView!
    
    // MARK: - Private constants

    // MARK: - Private variables
    private var lowImage: UIImage?
    private var dataTask: URLSessionDataTask?
    
    private var imageModel: ImageURLs?
    private var isSelectedImage = false
    
    // MARK: - Lifecycle
    override func prepareForReuse() {
        super.prepareForReuse()
        isSelectedImage = false
        imageView.image = nil
        lowImage = nil
        updateSelectedState(isSelected: isSelectedImage)
        spinner.startAnimating()
        stopTask()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
        
    // MARK: - IBActions
    
    // MARK: - Public methods
    public func setup(_ imageModel: ImageURLs, isSelected: Bool) {
        updateSelectedState(isSelected: isSelected)
        self.imageModel = imageModel
        self.dataTask = RequestService.shared.loadImage(urlString: imageModel.thumb) { result  in
            guard let image = result else {
                return
            }
            self.lowImage = image
            self.updateImageView(lowImage: self.lowImage)
            self.stopTask()
        }
    }
    
    // MARK: - Private methods
    private func updateSelectedState(isSelected: Bool) {
        if isSelected {
            self.selectionMask.isHidden = false
        } else {
            self.selectionMask.isHidden = true
        }
    }
    
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
