//
//  ImageProgressComponentView.swift
//  AppStoreClone
//
//  Created by yjc on 2023/03/20.
//

import UIKit

final class ImageProgressComponentView: UIView {
    private let maskLayer = CAShapeLayer()
    let fillImageView = UIImageView(image: UIImage(systemName: "star.fill"))
    let guideImageView = UIImageView(image: UIImage(systemName: "star"))
    
    var progress: CGFloat = 0 {
        didSet {
            self.setProgress()
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.setProgress()
    }
    
    private func setupUI() {
        [self.guideImageView, self.fillImageView, ].forEach { view in
            self.addSubview(view)
            view.snp.makeConstraints { $0.edges.equalToSuperview() }
            view.contentMode = .scaleAspectFit
        }
        
        self.layer.addSublayer(self.maskLayer)
        self.maskLayer.backgroundColor = UIColor.black.cgColor
        self.fillImageView.layer.mask = self.maskLayer
    }
    
    private func setProgress() {
        var newFrame = self.fillImageFrame()
        newFrame.size.width *= self.progress
        self.maskLayer.frame = newFrame
    }
    
    private func fillImageFrame() -> CGRect {
        guard let imageSize = self.fillImageView.image?.size else { return .zero }
        let viewSize = self.fillImageView.frame.size
        
        let scaleWidth = viewSize.width / imageSize.width
        let scaleHeigh = viewSize.height / imageSize.height

        let width = imageSize.width * scaleWidth
        let height = imageSize.height * scaleHeigh
        let x = viewSize.width - width
        let y = viewSize.height - height
        
        return CGRect(x: x, y: y, width: width, height: height)
    }
}

