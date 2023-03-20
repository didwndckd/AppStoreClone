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

final class SearchResultViewController: BaseViewController, StoryboardBased, ViewModelBased {
    private let disposeBag = DisposeBag()
    var viewModel: SearchResultViewModel!
    private let selectedRecommendKeyword = PublishRelay<Int>()
    private let selectedSoftware = PublishRelay<Int>()
    
    @IBOutlet private weak var recommendKeywordTabelView: UITableView!
    @IBOutlet private weak var searchResultTabelView: UITableView!
    
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
    }
}

extension SearchResultViewController {
    private func bindUI() {
        let input = ViewModelType.Input(selectedRecommendKeyword: self.selectedRecommendKeyword.asSignal())
        let output = self.viewModel.transform(input: input)
        
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
}

extension SearchResultViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        WindowService.shared.window?.endEditing(true)
        switch tableView {
        case self.recommendKeywordTabelView:
            self.selectedRecommendKeyword.accept(indexPath.row)
        case self.searchResultTabelView:
            self.selectedSoftware.accept(indexPath.row)
        default:
            break
        }
        
    }
}
