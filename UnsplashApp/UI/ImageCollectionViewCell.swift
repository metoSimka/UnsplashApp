//
//  ImageCollectionViewCell.swift
//  UnsplashApp
//
//  Created by metoSimka on 26.10.2020.
//  Copyright © 2020 metoSimka. All rights reserved.
//

import UIKit

protocol ImageCellDelegate: class {
    func doubleTapCell(_ cell: ImageCollectionViewCell)
}

class ImageCollectionViewCell: UICollectionViewCell {
    
    weak var delegate: ImageCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addDoubleTap()
    }
    
    private func addDoubleTap() {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(doubleTapCell))
        doubleTap.numberOfTapsRequired = 2
        self.addGestureRecognizer(doubleTap)
    }
    
    @objc private func doubleTapCell() {
        self.delegate?.doubleTapCell(self)
    }
}
