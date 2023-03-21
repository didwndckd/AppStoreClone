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
    private let selectedLatestSearchKeyword = PublishRelay<Int>()
    
    @IBOutlet private weak var tableView: UITableView!
    private lazy var searchController: UISearchController = {
        let searchResultController = SearchResultViewController.instantiate(withViewModel: self.viewModel.searchResultViewModel)
        return UISearchController(searchResultsController: searchResultController)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.bindUI()
    }
    
    private func setupNavigationBar() {
        self.title = "검색"
        self.setupSearchController()
    }
    
    private func setupSearchController() {
        self.searchController.searchBar.placeholder = "게임, 앱, 스토리 등"
        self.searchController.searchBar.delegate = self
        self.navigationItem.searchController = self.searchController
        self.navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    private func setupUI() {
        self.setupNavigationBar()
        self.tableView.register(LatestSearchKeywordCell.self)
        self.tableView.register(LatestSearchKeywordHeaderView.self)
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.sectionHeaderHeight = 58
    }
}

extension SearchViewController {
    private func bindUI() {
        let input = ViewModelType.Input(searchKeyword: self.searchKeyword.asSignal(),
                                        search: self.search.asSignal(),
                                        selectedLatestSearchKeyword: self.selectedLatestSearchKeyword.asSignal())
        
        let output = self.viewModel.transform(input: input)
        output.reload
            .drive(onNext: { [weak self] in
                self?.tableView.reloadData()
            })
            .disposed(by: self.disposeBag)
        
        output.searchKeyword
            .drive(self.searchController.searchBar.rx.text)
            .disposed(by: self.disposeBag)
        
        output.isSearchMode
            .filter { $0 }
            .drive(self.searchController.rx.isActive)
            .disposed(by: self.disposeBag)
        
        output.moveTo
            .drive(onNext: { [weak self] moveTo in
                switch moveTo {
                case .softwareDetail(let item):
                    self?.pushDetail(item: item)
                }
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
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(LatestSearchKeywordHeaderView.self)
        return view
    }
}

// MARK: UITableViewDelegate
extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedLatestSearchKeyword.accept(indexPath.row)
        WindowService.shared.window?.endEditing(true)
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
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchKeyword.accept("")
    }
}

// MARK: Moveto
extension SearchViewController {
    private func pushDetail(item: SoftwareItem) {
        let viewModel = SoftwareDetailViewModel(softwareItem: item)
        let viewController = SoftwareDetailViewController.instantiate(withViewModel: viewModel)
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}
