//
//  SoftwareDetailPreviewContentCell.swift
//  AppStoreClone
//
//  Created by yjc on 2023/03/21.
//

import UIKit

final class SoftwareDetailPreviewContentCell: UICollectionViewCell, ReusableView, NibLoadableView {

    @IBOutlet private weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupUI()
    }
    
    private func setupUI() {
        self.imageView.layer.cornerRadius = 8
    }
    
    func configure(url: URL?) {
        guard let url = url else {
            self.imageView.image = nil
            return
        }
        self.imageView.setImage(url)
    }
}
