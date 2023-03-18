//
//  LatestSearchKeywordCell.swift
//  AppStoreClone
//
//  Created by yjc on 2023/03/18.
//

import UIKit

final class LatestSearchKeywordCell: UITableViewCell, NibLoadableView, ReusableView {

    @IBOutlet private weak var keywordLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(keyword: String) {
        self.keywordLabel.text = keyword
    }
}
