//
//  CollectionTableViewCell.swift
//  fyndProduct
//
//  Created by Prayag on 01/03/20.
//  Copyright © 2020 Prayag. All rights reserved.
//

import UIKit

class CollectionTableViewCell: UITableViewCell {

    @IBOutlet weak var productCollectionView: UICollectionView!
    @IBOutlet weak var lblCategoryName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        productCollectionView.register(UINib(nibName: "CollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CollectionViewCell")
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setCollectionViewDataSourceDelegate(dataSourceDelegate: UICollectionViewDataSource & UICollectionViewDelegate & UICollectionViewDragDelegate & UICollectionViewDropDelegate, forRow row: Int) {
        productCollectionView.delegate = dataSourceDelegate
        productCollectionView.dataSource = dataSourceDelegate
        productCollectionView.tag = row
        productCollectionView.dragDelegate = dataSourceDelegate
        productCollectionView.dropDelegate = dataSourceDelegate
        productCollectionView.dragInteractionEnabled = true
        productCollectionView.reloadData()
    }
    
}
