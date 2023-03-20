//
//  DefaultLoadingView.swift
//  AppStoreClone
//
//  Created by yjc on 2023/03/21.
//

import UIKit

final class DefaultLoadingView: UIView {
    private let stackView = UIStackView()
    private let indicatorView = UIActivityIndicatorView()
    private let descriptionLabel = UILabel()
    
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
        self.stackView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.trailing.equalToSuperview()
        }
        self.stackView.axis = .vertical
        self.stackView.alignment = .center
        self.stackView.spacing = 8
        
        [self.indicatorView, self.descriptionLabel].forEach { self.stackView.addArrangedSubview($0) }
        
        self.descriptionLabel.textColor = .secondaryLabel
        self.descriptionLabel.font = .boldSystemFont(ofSize: 12)
        self.descriptionLabel.text = "로드중"
    }
}

extension DefaultLoadingView: LoadingView {
    func startLoading() {
        self.indicatorView.startAnimating()
    }
    func stopLoading() {
        self.indicatorView.stopAnimating()
    }
}
