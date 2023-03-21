//
//  SoftwareDetailNewFeatureCell.swift
//  AppStoreClone
//
//  Created by yjc on 2023/03/21.
//

import UIKit
import RxSwift
import RxCocoa

final class SoftwareDetailNewFeatureCell: UITableViewCell, NibLoadableView, ReusableView {
    typealias Item = SoftwareDetailViewModel.NewFeatureItem

    private let disposeBag = DisposeBag()
    @IBOutlet private weak var versionLabel: UILabel!
    @IBOutlet private weak var releaseDateLabel: UILabel!
    @IBOutlet private weak var releaseNotesLabel: UILabel!
    @IBOutlet private weak var moreButtonWrapperView: UIView!
    @IBOutlet private weak var moreButton: UIButton!
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
        
        let bounds = CGRect(origin: .zero, size: CGSize(width: self.releaseNotesLabel.bounds.width, height: CGFloat(Int.max)))
        let fullTextHeight = self.releaseNotesLabel.textRect(forBounds: bounds,
                                                             limitedToNumberOfLines: 0).height
        let textHeight = self.releaseNotesLabel.textRect(forBounds: self.releaseNotesLabel.bounds,
                                                         limitedToNumberOfLines: self.releaseNotesLabel.numberOfLines).height
        self.moreButtonWrapperView.isHidden = fullTextHeight <= textHeight
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
    
    private func setupReleaseDateLabel(date: Date?) {
        guard let date = date else {
            self.releaseDateLabel.text = nil
            return
        }
        
        let timeInterval = -date.timeIntervalSinceNow
        let dayInterval = Int(timeInterval / .oneDay)
        
        if timeInterval < .oneHour {
            let minute = Int(timeInterval / .oneMinute)
            self.releaseDateLabel.text = "\(minute)분 전"
        }
        else if timeInterval < .oneDay {
            let hours = Int(timeInterval / .oneHour)
            self.releaseDateLabel.text = "\(hours)시간 전"
        }
        else if dayInterval < 7 {
            self.releaseDateLabel.text = "\(dayInterval)일 전"
        }
        else if dayInterval < 36 {
            self.releaseDateLabel.text = "\(dayInterval / 7)주 전"
        }
        else if dayInterval < 366 {
            self.releaseDateLabel.text = "\(dayInterval / 30)개월 전"
        }
        else {
            self.releaseDateLabel.text = "\(dayInterval / 365)년 전"
        }
    }
}

extension SoftwareDetailNewFeatureCell {
    func configure(item: Item) {
        self.item = item
        self.versionLabel.text = item.version
        self.setupReleaseDateLabel(date: item.releaseDate)
        self.releaseNotesLabel.text = item.releaseNotes
        self.releaseNotesLabel.numberOfLines = item.isFold ? 3: 0
        self.moreButtonWrapperView.isHidden = !item.isFold
    }
}
