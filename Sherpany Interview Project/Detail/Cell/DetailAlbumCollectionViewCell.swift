//
//  DetailAlbumCollectionViewCell.swift
//  Sherpany Interview Project
//
//  Created by Dante Puglisi on 7/26/18.
//  Copyright © 2018 Dante Puglisi. All rights reserved.
//

import UIKit
import AlamofireImage

class DetailAlbumCollectionViewCell: UICollectionViewCell {
    
    var cellAlbum: Album!
    
    @IBOutlet weak var viewBackground: UIView! {
        didSet {
            viewBackground.layer.cornerRadius = 10.0
            viewBackground.clipsToBounds = true
        }
    }
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var photosCountLabel: UILabel!
    
    func setupUI(withAlbum albumReceived: Album) {
        cellAlbum = albumReceived
        
        if let photos = cellAlbum.photos?.array as? [Photo] {
            photosCountLabel.text = "\(photos.count) photos"
            if let firstPhoto = photos.first, let firstPhotoString = firstPhoto.url {
                photoImageView.af_setImage(withURL: URL(string: firstPhotoString)!, imageTransition: .crossDissolve(0.2), runImageTransitionIfCached: false)
            }
        }
    }
    
    override func prepareForReuse() {
        photoImageView.image = nil
        photoImageView.af_cancelImageRequest()
    }
}
