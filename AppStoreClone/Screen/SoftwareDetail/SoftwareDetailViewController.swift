//
//  SoftwareDetailViewController.swift
//  AppStoreClone
//
//  Created by yjc on 2023/03/21.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

final class SoftwareDetailViewController: BaseViewController, StoryboardBased, ViewModelBased {
    private let disposeBag = DisposeBag()
    var viewModel: SoftwareDetailViewModel!
    
    private let iconButton = UIButton()
    private let downloadBarButton = UIButton()
    @IBOutlet private weak var tableView: UITableView!
    private var headerCell: SoftwareDetailHeaderCell?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.setupAction()
        self.bindUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        [self.downloadBarButton].forEach { view in
            view.layer.cornerRadius = view.frame.height / 2
        }
    }
    
    private func setupNavigationBar() {
        self.navigationItem.largeTitleDisplayMode = .never
        
        let titleView = UIView()
        titleView.addSubview(self.iconButton)
        self.iconButton.snp.makeConstraints { $0.edges.equalToSuperview() }
        self.navigationItem.titleView = titleView
        
        let downloadBarButtonContainerView = UIView()
        downloadBarButtonContainerView.addSubview(self.downloadBarButton)
        self.downloadBarButton.snp.makeConstraints { $0.edges.equalToSuperview() }
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: downloadBarButtonContainerView)
    }
    
    private func setupUI() {
        self.setupNavigationBar()
        
        self.setupDownloadBarButton()
        self.iconButton.clipsToBounds = true
        self.iconButton.layer.cornerRadius = 8
        self.iconButton.snp.makeConstraints { make in
            make.width.height.equalTo(28)
        }
        
        [self.iconButton, self.downloadBarButton].forEach { view in
            view.alpha = 0
            view.transform = CGAffineTransform(translationX: 0, y: 4)
        }
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.separatorStyle = .none
        self.tableView.register(SoftwareDetailHeaderCell.self)
        self.tableView.register(SoftwareDetailNewFeatureCell.self)
        self.tableView.register(SoftwareDetailPreviewCell.self)
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "spacing")
    }
    
    private func setupAction() {
        self.iconButton.rx.tap
            .bind(onNext: { [weak self] in
                self?.tableView.setContentOffset(.zero, animated: true)
            })
            .disposed(by: self.disposeBag)
    }
    
    private func setupDownloadBarButton() {
        self.downloadBarButton.backgroundColor = .link
        self.downloadBarButton.setTitle("받기", for: .normal)
        self.downloadBarButton.setTitleColor(.white, for: .normal)
        
        let vInset: CGFloat = 4
        let hInset: CGFloat = 20
        let font = UIFont.boldSystemFont(ofSize: 16)
        if #available(iOS 15.0, *) {
            var config = UIButton.Configuration.plain()
            config.contentInsets = .init(top: vInset, leading: hInset, bottom: vInset, trailing: hInset)
            config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
                var result = incoming
                result.font = font
                return result
            }
            self.downloadBarButton.configuration = config
        } else {
            self.downloadBarButton.contentEdgeInsets = UIEdgeInsets(top: vInset, left: hInset, bottom: vInset, right: hInset)
            self.downloadBarButton.titleLabel?.font = font
        }
    }
    
    private func updateHeaderSectionHiddenMode(scrollOffsetY: CGFloat) {
        guard let headerCell = self.headerCell else { return }
        
        let isHidden = scrollOffsetY >= headerCell.hiddenOffset

        guard isHidden != headerCell.isHiddenMode else { return }

        UIView.animate(withDuration: 0.3, delay: 0, options: .beginFromCurrentState, animations: { [weak self] in
            headerCell.setHiddenMode(isHidden: isHidden)

            [self?.iconButton, self?.downloadBarButton].forEach { view in
                view?.alpha = isHidden ? 1: 0
                view?.transform = isHidden ? .identity: CGAffineTransform(translationX: 0, y: 4)
            }
        })
    }
}

extension SoftwareDetailViewController {
    private func bindUI() {
        let input = ViewModelType.Input()
        let output = self.viewModel.transform(input: input)
        
        output.smallIconUrl
            .drive(onNext: { [weak self] url in
                self?.iconButton.setImage(url, for: .normal)
            })
            .disposed(by: self.disposeBag)
        
        output.reload
            .drive(onNext: { [weak self] in
                self?.tableView.reloadData()
            })
            .disposed(by: self.disposeBag)
    }
}

extension SoftwareDetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.numberOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let rowType = self.viewModel.row(index: indexPath.row)
        switch rowType {
        case .header(let item):
            let cell = tableView.dequeueReusableCell(SoftwareDetailHeaderCell.self, for: indexPath)
            cell.configure(item: item)
            return cell
        case .newFeature(let item):
            let cell = tableView.dequeueReusableCell(SoftwareDetailNewFeatureCell.self, for: indexPath)
            cell.configure(item: item)
            cell.more = { [weak self] in self?.tableView.reloadRows(at: [indexPath], with: .fade) }
            return cell
        case .preview(let item):
            let cell = tableView.dequeueReusableCell(SoftwareDetailPreviewCell.self, for: indexPath)
            cell.configure(item: item)
            return cell
        default:
            return self.tableView.dequeueReusableCell(withIdentifier: "spacing", for: indexPath)
        }
    }
}

extension SoftwareDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let row = self.viewModel.row(index: indexPath.row)
        switch row {
        case .spacing(let spacing):
            return spacing
        default:
            return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let headerCell = cell as? SoftwareDetailHeaderCell else { return }
        self.headerCell = headerCell
    }
}

// MARK: UIScrollViewDelegate
extension SoftwareDetailViewController {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.updateHeaderSectionHiddenMode(scrollOffsetY: scrollView.contentOffset.y)
    }
}
