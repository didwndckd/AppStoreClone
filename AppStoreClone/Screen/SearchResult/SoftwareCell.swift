//
//  SoftwareCell.swift
//  AppStoreClone
//
//  Created by yjc on 2023/03/20.
//

import UIKit

final class SoftwareCell: UITableViewCell, ReusableView, NibLoadableView {

    @IBOutlet private weak var iconImageView: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var categoryLabel: UILabel!
    @IBOutlet private weak var avertageUserRatingView: AverageUserRatingView!
    @IBOutlet private weak var userRatingCountLabel: UILabel!
    @IBOutlet private weak var downloadButton: UIButton!
    @IBOutlet private weak var screenshotImageView1: UIImageView!
    @IBOutlet private weak var screenshotImageView2: UIImageView!
    @IBOutlet private weak var screenshotImageView3: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupUI()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.downloadButton.layer.cornerRadius = self.downloadButton.bounds.height / 2
    }
    
    private func setupUI() {
        self.selectionStyle = .none
        self.iconImageView.layer.cornerRadius = 16
        self.iconImageView.layer.borderWidth = 0.5
        self.iconImageView.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
        
        [self.screenshotImageView1, self.screenshotImageView2, self.screenshotImageView3].forEach { view in
            view?.layer.cornerRadius = 8
            view?.layer.borderColor = UIColor.lightGray.cgColor
            view?.layer.borderWidth = 0.5
        }
    }
    
    func configure(item: SoftwareItem) {
        self.nameLabel.text = item.name
        self.categoryLabel.text = item.categorys.first ?? ""
        self.avertageUserRatingView.value = item.averageUserRating
        self.userRatingCountLabel.text = item.userRatingCount.toSimpleCountText()
        self.iconImageView.setImage(item.iconUrl512)
        self.screenshotImageView1.setImage(item.screenshotUrls.safety(index: 0) ?? "")
        self.screenshotImageView2.setImage(item.screenshotUrls.safety(index: 1) ?? "")
        self.screenshotImageView3.setImage(item.screenshotUrls.safety(index: 2) ?? "")
        
        let multiplier = item.screenShotImageHeightMultiPlier
        [self.screenshotImageView2, self.screenshotImageView3].forEach { $0?.isHidden = multiplier < 1 }
        
        self.screenshotImageView1.snp.remakeConstraints { remake in
            remake.height.equalTo(self.screenshotImageView1.snp.width).multipliedBy(multiplier)
        }
    }
    
}
