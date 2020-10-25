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
    
    // MARK: - Private constants
    
    // MARK: - Private variables
    private var lowImage: UIImage?
    private var dataTask: URLSessionDataTask?
    
    private var imageModel: ImageURLs?
    
    // MARK: - Lifecycle
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        lowImage = nil
        spinner.startAnimating()
        stopTask()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        updateImageView(lowImage: lowImage)
        addDoubleTap()
    }
        
    // MARK: - IBActions
    
    // MARK: - Public methods
    public func setup(_ imageModel: ImageURLs) {
        self.imageModel = imageModel
        guard let thumbUrl: URL = URL(string: imageModel.thumb ) else {
            return
        }
        self.dataTask = RequestService.shared.loadImage(url: thumbUrl) { image in
            self.lowImage = image
            self.updateImageView(lowImage: self.lowImage)
            self.stopTask()
        }
    }
    
    // MARK: - Private methods
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
