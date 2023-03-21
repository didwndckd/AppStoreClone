//
//  SoftwareDetailDescriptionCell.swift
//  AppStoreClone
//
//  Created by yjc on 2023/03/22.
//

import UIKit
import RxSwift
import RxCocoa

final class SoftwareDetailDescriptionCell: UITableViewCell, ReusableView, NibLoadableView {
    typealias Item = SoftwareDetailViewModel.DescriptionItem
    private let disposeBag = DisposeBag()
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var moreButtonWrapperView: UIView!
    @IBOutlet private weak var moreButton: UIButton!
    @IBOutlet private weak var developerNameLabel: UILabel!
    private var item: Item?
    var more: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupUI()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.moreButtonWrapperView.layer.applySketchShadow(color: .systemBackground, alpha: 1, blur: 5)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.moreButtonWrapperView.layer.updateCurrentShadowPath()
        self.setupMoreButtonHidden()
    }

    private func setupUI() {
        self.moreButtonWrapperView.layer.applySketchShadow(color: .systemBackground, alpha: 1, blur: 8)
        
        self.moreButton.rx.tap
            .bind(onNext: { [weak self] in
                self?.item?.isFold = false
                self?.more?()
            })
            .disposed(by: self.disposeBag)
    }
}

extension SoftwareDetailDescriptionCell {
    private func setupMoreButtonHidden() {
        let numberOfLines = self.item?.description.split(separator: "\n").count ?? 0
        let isFold = self.item?.isFold == true
        if isFold && numberOfLines < 4 {
            self.moreButtonWrapperView.isHidden = !self.descriptionLabel.isMoreText
        }
        else {
            self.moreButtonWrapperView.isHidden = !isFold
        }
    }
}

extension SoftwareDetailDescriptionCell {
    func configure(item: Item) {
        self.item = item
        self.descriptionLabel.text = self.item?.description
        self.developerNameLabel.text = self.item?.developerName
        self.descriptionLabel.numberOfLines = item.isFold ? 3: 0
        self.moreButtonWrapperView.isHidden = !item.isFold
    }
}
