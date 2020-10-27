//
//  LibraryImageCollectionViewCell.swift
//  UnsplashApp
//
//  Created by metoSimka on 26.10.2020.
//  Copyright © 2020 metoSimka. All rights reserved.
//

import UIKit

class LibraryImageCollectionViewCell: ImageCollectionViewCell {
    
    var image: UIImage?
    
    // MARK: - Private variables
    private var isSelectedImage = false
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var selectionMask: UIView!
    @IBOutlet weak var imageView: UIImageView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        spinner.startAnimating()
        isSelectedImage = false
        self.updateSelectedState(isSelected: isSelected)
        self.image = nil
        self.imageView.image = nil
    }
    
    public func setup(imageData: Data, isSelected: Bool) {
        guard let image = UIImage(data: imageData) else {
            return
        }
        
        self.imageView.image = image
        spinner.stopAnimating()
        updateSelectedState(isSelected: isSelected)
    }
    
    private func updateSelectedState(isSelected: Bool) {
        if isSelected {
            self.selectionMask.isHidden = false
        } else {
            self.selectionMask.isHidden = true
        }
    }
}
