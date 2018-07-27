//
//  DetailAlbumCollectionViewCell.swift
//  Sherpany Interview Project
//
//  Created by Dante Puglisi on 7/26/18.
//  Copyright © 2018 Dante Puglisi. All rights reserved.
//

import UIKit

class DetailAlbumCollectionViewCell: UICollectionViewCell {
    
    var cellAlbum: Album!
    
    @IBOutlet weak var viewBackground: UIView! {
        didSet {
            viewBackground.layer.cornerRadius = 6.0
            viewBackground.clipsToBounds = true
        }
    }
    @IBOutlet weak var photoImageView: UIImageView!
    
    func setupUI(withAlbum albumReceived: Album) {
        cellAlbum = albumReceived
        
        if let photos = cellAlbum.photos?.array as? [Photo] {
            if let firstPhoto = photos.first {
                firstPhoto.
            }
        }
    }
}
