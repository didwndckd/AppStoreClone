//
//  SoftwareDetailPreviewCell.swift
//  AppStoreClone
//
//  Created by yjc on 2023/03/21.
//

import UIKit

final class SoftwareDetailPreviewCell: UITableViewCell, ReusableView, NibLoadableView {
    typealias Item = SoftwareDetailViewModel.PreviewItem
    private var baseSize = CGSize.zero
    
    @IBOutlet private weak var collectionView: UICollectionView!
    private var item: Item?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupUI()
    }
    
    private func setupUI() {
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.register(SoftwareDetailPreviewContentCell.self)
        self.collectionView.decelerationRate = .fast
    }
}

extension SoftwareDetailPreviewCell {
    private var lineSpacing: CGFloat { 8 }
    
    private var hInset: CGFloat { self.lineSpacing * 2 }
    
    private var heightMultiplier: CGFloat {
        let result = self.baseSize.height / self.baseSize.width
        return result.isNaN ? 0: result
    }
    
    private var isVertical: Bool {
        return self.heightMultiplier > 1
    }
    
    private func calculateItemWidth(baseWidth: CGFloat) -> CGFloat {
        if self.isVertical {
            // 아이템 한개 반 걸치게
            return (baseWidth - self.hInset - self.lineSpacing) / 3 * 2
        }
        else {
            return baseWidth - self.hInset * 2
        }
    }
    
    private func calculateIndex(offset: CGFloat) -> Int {
        let offset = offset + self.hInset
        let itemWidth = self.calculateItemWidth(baseWidth: self.collectionView.bounds.width)
        let itemSpace = itemWidth + self.lineSpacing
        let result = round(offset / itemSpace)
        return Int(result)
    }
    
    private func calculateOffset(index: Int) -> CGFloat {
        guard index > 0 else { return 0 }
        let itemWidth = self.calculateItemWidth(baseWidth: self.collectionView.bounds.width)
        let totalItemsWidth = itemWidth * CGFloat(index)
        let totalLineSpacing = self.lineSpacing * CGFloat(index - 1)
        return self.hInset + totalItemsWidth + totalLineSpacing - self.lineSpacing
    }
}

extension SoftwareDetailPreviewCell {
    func configure(item: Item) {
        self.item = item
        let screenshotItem = item.screenshotItems.first
        self.baseSize = CGSize(width: screenshotItem?.width ?? 0, height: screenshotItem?.height ?? 0)
        
        let screenWidth = WindowService.shared.window?.bounds.width ?? 0
        let height = self.calculateItemWidth(baseWidth: screenWidth) * self.heightMultiplier
        self.collectionView.snp.remakeConstraints { remake in
            remake.height.equalTo(height)
        }
        
        self.collectionView.reloadData()
        self.collectionView.contentOffset.x = self.calculateOffset(index: item.currentIndex)
    }
}

extension SoftwareDetailPreviewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.item?.screenshotItems.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(SoftwareDetailPreviewContentCell.self, for: indexPath)
        let url = self.item?.screenshotItems.safety(index: indexPath.item)?.url
        cell.configure(url: url)
        return cell
    }
}

extension SoftwareDetailPreviewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: self.hInset, bottom: 0, right: self.hInset)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return self.lineSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.calculateItemWidth(baseWidth: collectionView.bounds.width)
        let height = floor(width * self.heightMultiplier)
        return CGSize(width: width, height: height)
    }
}

extension SoftwareDetailPreviewCell: UICollectionViewDelegate {
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        var index = self.item?.currentIndex ?? 0
        let targetIndex = self.calculateIndex(offset: targetContentOffset.pointee.x)
        
        if index > targetIndex {
            index -= 1
        }
        else if index < targetIndex {
            index += 1
        }
        
        self.item?.currentIndex = index
        let offset = self.calculateOffset(index: index)
        targetContentOffset.pointee.x = offset
    }
}
