//
//  SearchViewController.swift
//  AppStoreClone
//
//  Created by yjc on 2023/03/18.
//

import UIKit
import RxSwift
import RxCocoa

final class SearchViewController: BaseViewController, ViewModelBased, StoryboardBased {
    private let disposeBag = DisposeBag()
    var viewModel: SearchViewModel!
    private let searchKeyword = PublishRelay<String>()
    private let search = PublishRelay<Void>()
    
    @IBOutlet private weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupNavigation()
        self.setupUI()
        self.bindUI()
    }
    
    private func setupNavigation() {
        self.title = "검색"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.setupSearchController()
    }
    
    private func setupSearchController() {
        let searchResultController = SearchResultViewController.instantiate(withViewModel: self.viewModel.searchResultViewModel)
        let searchController = UISearchController(searchResultsController: searchResultController)
        searchController.searchBar.placeholder = "게임, 앱, 스토리 등"
        self.navigationItem.searchController = searchController
        self.navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    private func setupUI() {
        self.tableView.register(LatestSearchKeywordCell.self)
        self.tableView.dataSource = self
        self.tableView.delegate = self
    }
}

extension SearchViewController {
    private func bindUI() {
        let input = ViewModelType.Input(searchKeyword: self.searchKeyword.asSignal(),
                                        search: self.search.asSignal())
        let output = self.viewModel.transform(input: input)
        output.reload
            .drive(onNext: { [weak self] in
                self?.tableView.reloadData()
            })
            .disposed(by: self.disposeBag)
    }
}

// MARK: UITableViewDataSource
extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.numberOfLatestKeywords
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(LatestSearchKeywordCell.self, for: indexPath)
        let keyword = self.viewModel.latestKeyword(index: indexPath.row)
        cell.configure(keyword: keyword)
        return cell
    }
}

// MARK: UITableViewDelegate
extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

// MARK: UISearchBarDelegate
extension SearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchKeyword.accept(searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.search.accept(())
    }
}