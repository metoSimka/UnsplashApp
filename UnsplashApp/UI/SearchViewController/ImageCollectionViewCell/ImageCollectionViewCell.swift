//
//  ImageCollectionViewCell.swift
//  UnsplashApp
//
//  Created by metoSimka on 19.10.2020.
//  Copyright © 2020 metoSimka. All rights reserved.
//

import UIKit

protocol ImageCollectionViewCellDelegate: class {
    func doubleTapCell(_ cell: ImageCollectionViewCell)
}

class ImageCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Public constants
    weak var delegate: ImageCollectionViewCellDelegate?
    
    // MARK: - Public variables

    // MARK: - IBOutlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var selectionMask: UIView!
    
    // MARK: - Private constants
    private let animationTime: TimeInterval = 0.1
    
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
        addDoubleTap()
    }
        
    // MARK: - IBActions
    
    // MARK: - Public methods
    public func setup(_ imageModel: ImageURLs, isSelected: Bool) {
        updateSelectedState(isSelected: isSelected)
        self.imageModel = imageModel
        self.dataTask = RequestService.shared.loadImage(urlString: imageModel.thumb) { image in
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

    private func addDoubleTap() {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(doubleTapCell))
        doubleTap.numberOfTapsRequired = 2
        self.addGestureRecognizer(doubleTap)
    }
    
    @objc private func doubleTapCell() {
        self.delegate?.doubleTapCell(self)
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
