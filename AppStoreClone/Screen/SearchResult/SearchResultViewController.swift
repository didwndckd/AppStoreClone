//
//  SearchResultViewController.swift
//  AppStoreClone
//
//  Created by yjc on 2023/03/18.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

final class SearchResultViewController: BaseViewController, StoryboardBased, ViewModelBased, Loadable {
    private let disposeBag = DisposeBag()
    var viewModel: SearchResultViewModel!
    private let selectedRecommendKeyword = PublishRelay<Int>()
    private let selectedSoftware = PublishRelay<Int>()
    private let nextPage = PublishRelay<Void>()
    
    @IBOutlet private weak var recommendKeywordTabelView: UITableView!
    @IBOutlet private weak var searchResultTabelView: UITableView!
    private let searchResultNextPageIndicator = UIActivityIndicatorView()
    private let searchResultFooterView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.bindUI()
    }
    
    private func setupUI() {
        self.recommendKeywordTabelView.register(RecommendSearchKeywordCell.self)
        self.recommendKeywordTabelView.dataSource = self
        self.recommendKeywordTabelView.delegate = self
        
        self.searchResultTabelView.separatorStyle = .none
        self.searchResultTabelView.register(SoftwareCell.self)
        self.searchResultTabelView.dataSource = self
        self.searchResultTabelView.delegate = self
        
        self.searchResultFooterView.addSubview(self.searchResultNextPageIndicator)
        self.searchResultNextPageIndicator.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        self.searchResultTabelView.tableFooterView = self.searchResultFooterView
        self.searchResultFooterView.frame.size.height = 100
    }
}

extension SearchResultViewController {
    private func bindUI() {
        let input = ViewModelType.Input(selectedRecommendKeyword: self.selectedRecommendKeyword.asSignal(),
                                        nextPage: self.nextPage.asSignal())
        let output = self.viewModel.transform(input: input)
        
        output.searchLoading
            .drive(onNext: { [weak self] loading in
                self?.loading(loading)
            })
            .disposed(by: self.disposeBag)
        
        output.nextPageLoading
            .drive(onNext: { [weak self] loading in
                if loading {
                    self?.searchResultNextPageIndicator.startAnimating()
                }
                else {
                    self?.searchResultNextPageIndicator.stopAnimating()
                }
            })
            .disposed(by: self.disposeBag)
        
        output.reloadRecommendKeywordList
            .drive(onNext: { [weak self] in
                self?.recommendKeywordTabelView.reloadData()
            })
            .disposed(by: self.disposeBag)
        
        output.reloadSoftwareItems
            .drive(onNext: { [weak self] in
                self?.searchResultTabelView.reloadData()
            })
            .disposed(by: self.disposeBag)
        
        output.mode
            .drive(onNext: { [weak self] mode in
                self?.recommendKeywordTabelView.isHidden = mode != .recommendKeyword
                self?.searchResultTabelView.isHidden = mode != .software
            })
            .disposed(by: self.disposeBag)
    }
}

// MARK: UITableViewDataSource
extension SearchResultViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableView {
        case self.recommendKeywordTabelView:
            return self.viewModel.numberOfRecommendKeywordList
        case self.searchResultTabelView:
            return self.viewModel.numberOfSoftwareItems
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch tableView {
        case self.recommendKeywordTabelView:
            let cell = tableView.dequeueReusableCell(RecommendSearchKeywordCell.self, for: indexPath)
            let keyword = self.viewModel.recommendKeyword(index: indexPath.row)
            cell.configure(keyword: keyword)
            return cell
        case self.searchResultTabelView:
            let cell = tableView.dequeueReusableCell(SoftwareCell.self, for: indexPath)
            let item = self.viewModel.softwareItem(index: indexPath.row)
            cell.configure(item: item)
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard tableView == self.searchResultTabelView, indexPath.row == self.viewModel.numberOfSoftwareItems - 1 else { return }
        self.nextPage.accept(())
    }
}

// MARK: UITableViewDelegate
extension SearchResultViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch tableView {
        case self.recommendKeywordTabelView:
            WindowService.shared.window?.endEditing(true)
            self.selectedRecommendKeyword.accept(indexPath.row)
        case self.searchResultTabelView:
            self.selectedSoftware.accept(indexPath.row)
        default:
            break
        }
    }
}
