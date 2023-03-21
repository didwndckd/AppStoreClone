//
//  AverageUserRatingView.swift
//  AppStoreClone
//
//  Created by yjc on 2023/03/20.
//

import UIKit

final class AverageUserRatingView: UIView {
    let stackView = UIStackView()
    private var componentVeiws: [ImageProgressComponentView] = []
    var value: CGFloat = 0 {
        didSet {
            self.setValue()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupUI()
    }
    
    private func setupUI() {
        self.addSubview(self.stackView)
        self.stackView.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        self.componentVeiws = (0...4).map { _ in
            let view = ImageProgressComponentView()
            view.fillImageView.tintColor = .gray
            view.guideImageView.tintColor = .gray
            self.setupComponentViewSize(view: view)
            return view
        }
        
        self.componentVeiws.forEach { self.stackView.addArrangedSubview($0) }
    }
    
    private func setupComponentViewSize(view: ImageProgressComponentView) {
        guard let imageSize = view.fillImageView.image?.size else { return }
        let widthMultiplier = imageSize.width / imageSize.height
        view.snp.makeConstraints { make in
            make.width.equalTo(view.snp.height).multipliedBy(widthMultiplier)
        }
    }
    
    private func setValue() {
        var currentValue = self.value
        self.componentVeiws.forEach { view in
            if currentValue > 0 {
                view.progress = min(1, currentValue)
            }
            else {
                view.progress = 0
            }
            currentValue -= 1
        }
    }
}

