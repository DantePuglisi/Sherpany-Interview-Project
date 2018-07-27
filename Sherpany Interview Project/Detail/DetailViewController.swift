//
//  DetailViewController.swift
//  Sherpany Interview Project
//
//  Created by Dante Puglisi on 7/25/18.
//  Copyright © 2018 Dante Puglisi. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    //MARK: - Outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    @IBOutlet weak var placeholderLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var collectionViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var bodyToCollectionViewConstraint: NSLayoutConstraint!
    
    //MARK: - Variables
    var detailItem: Post? {
        didSet {
            if let albumsSet = detailItem?.user?.albums, let albums = albumsSet.array as? [Album] {
                detailAlbums = albums
            }
        }
    }
    var detailAlbums: [Album]?
    
    let CELL_SIZE: CGFloat = 300
    let MIN_CELL_MARGIN: CGFloat = 80
    var cellInteritemSpace: CGFloat = 80
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.register(UINib(nibName: "DetailAlbumCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "cell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configureView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        calculateCollectionViewSize()
    }
    
    //MARK: - UI
    func configureView() {
        if let detailItem = detailItem {
            placeholderLabel.alpha = 0.0
            if let title = detailItem.title {
                titleLabel.text = title
                titleLabel.alpha = 1.0
            }
            if let body = detailItem.body {
                bodyLabel.text = body
                bodyLabel.alpha = 1.0
            }
            if detailAlbums?.count != 0 {
                collectionView.alpha = 1.0
            }
        } else {
            placeholderLabel.alpha = 1.0
            titleLabel.alpha = 0.0
            bodyLabel.alpha = 0.0
            collectionView.alpha = 0.0
        }
    }
    
    func calculateCollectionViewSize() {
        guard let detailAlbums = detailAlbums else { return }
        let totalWidth = self.view.frame.size.width
        let screenMargin = titleLabel.frame.origin.x
        
        let availSpace = totalWidth - screenMargin * 2
        
        var viewWidth = CELL_SIZE
        var columnsCount: CGFloat = 1
        
        while viewWidth + CELL_SIZE + MIN_CELL_MARGIN <= availSpace {
            viewWidth += CELL_SIZE + MIN_CELL_MARGIN
            columnsCount += 1
        }
        
        if columnsCount > 1 {
            cellInteritemSpace = viewWidth - (CELL_SIZE * columnsCount)
        } else {
            cellInteritemSpace = MIN_CELL_MARGIN
        }
        
        collectionViewWidthConstraint.constant = viewWidth
        
        collectionViewHeightConstraint.constant = ((CGFloat(detailAlbums.count) * (CELL_SIZE + cellInteritemSpace)) / columnsCount)
        
        bodyToCollectionViewConstraint.constant = cellInteritemSpace
    }
    
    //MARK: - CollectionView DataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let detailAlbums = detailAlbums else { return 0 }
        return detailAlbums.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! DetailAlbumCollectionViewCell
        
        if let detailAlbums = detailAlbums {
            cell.setupUI(withAlbum: detailAlbums[indexPath.item])
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: CELL_SIZE, height: CELL_SIZE)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return cellInteritemSpace
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return cellInteritemSpace
    }

}

