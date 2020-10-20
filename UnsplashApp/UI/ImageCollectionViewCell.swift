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
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    public func setImage(_ image: UIImage?) {
        guard let newImage = image else {
            spinner.startAnimating()
            return
        }
        spinner.stopAnimating()
        self.imageView.image = newImage
        
    }
    
    public func withoutImage() {
        spinner.startAnimating()
    }
}
