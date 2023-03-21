//
//  SoftwareDetailHeaderCell.swift
//  AppStoreClone
//
//  Created by yjc on 2023/03/21.
//

import UIKit

final class SoftwareDetailHeaderCell: UITableViewCell, ReusableView, NibLoadableView {
    typealias Item = SoftwareDetailViewModel.HeaderItem
    @IBOutlet private weak var iconImageView: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var categoryLabel: UILabel!
    @IBOutlet private weak var downloadButton: UIButton!
    @IBOutlet private weak var userRatingCountLabel: UILabel!
    @IBOutlet private weak var averageUserRatingLabel: UILabel!
    @IBOutlet private weak var averageUseRatingView: AverageUserRatingView!
    @IBOutlet private weak var ageLabel: UILabel!
    @IBOutlet private weak var developerNameLabel: UILabel!
    @IBOutlet private weak var languageLabel: UILabel!
    @IBOutlet private weak var languageCountLabel: UILabel!
    private var item: Item?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupUI()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.downloadButton.layer.cornerRadius = self.downloadButton.frame.height / 2
    }
    
    private func setupUI() {
        self.iconImageView.layer.cornerRadius = 16
        self.iconImageView.layer.borderWidth = 0.5
        self.iconImageView.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
    }
}

extension SoftwareDetailHeaderCell {
    func configure(item: Item) {
        self.item = item
        self.iconImageView.setImage(item.iconImageURL)
        self.nameLabel.text = item.name
        self.categoryLabel.text = item.category
        self.userRatingCountLabel.text = item.userRatingCount.toSimpleCountText() + "개의 평가"
        let numberFormatter = NumberFormatter()
        numberFormatter.maximumFractionDigits = 1
        self.averageUserRatingLabel.text = numberFormatter.string(from: item.averageUserRating as NSNumber)
        self.averageUseRatingView.value = item.averageUserRating
        self.ageLabel.text = item.ageText
        self.developerNameLabel.text = item.developer
        self.languageLabel.text = item.languageCode
        self.languageCountLabel.text = "+ \(item.languageCount)개 언어"
        self.setHiddenMode(isHidden: item.isHiddenMode)
    }
    
    var hiddenOffset: CGFloat {
        return self.frame.minY + self.downloadButton.frame.minY + 16
    }
    
    var isHiddenMode: Bool {
        return self.item?.isHiddenMode ?? false
    }
    
    func setHiddenMode(isHidden: Bool) {
        self.item?.isHiddenMode = isHidden
        [self.iconImageView, self.downloadButton].forEach { view in
            view.alpha = isHidden ? 0: 1
        }
    }
    
}
