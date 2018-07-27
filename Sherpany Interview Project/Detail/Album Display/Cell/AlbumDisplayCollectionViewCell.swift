//
//  AlbumDisplayCollectionViewCell.swift
//  Sherpany Interview Project
//
//  Created by Dante Puglisi on 7/27/18.
//  Copyright © 2018 Dante Puglisi. All rights reserved.
//

import UIKit
import AlamofireImage

class AlbumDisplayCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var cellImageView: UIImageView!
    
    func setupCell(withURLString urlReceived: String) {
        guard let url = URL(string: urlReceived) else { return }
        
        cellImageView.af_setImage(withURL: url, imageTransition: .crossDissolve(0.2), runImageTransitionIfCached: false)
    }
    
    override func prepareForReuse() {
        cellImageView.af_cancelImageRequest()
        cellImageView.image = nil
    }
}
