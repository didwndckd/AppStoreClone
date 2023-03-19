//
//  RecommendSearchKeywordCell.swift
//  AppStoreClone
//
//  Created by yjc on 2023/03/19.
//

import UIKit

final class RecommendSearchKeywordCell: UITableViewCell, ReusableView, NibLoadableView {
    
    @IBOutlet private weak var keywordLabel: UILabel!
    
    func configure(keyword: String) {
        self.keywordLabel.text = keyword
    }
}
