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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.bindUI()
    }
    
    private func setupUI() {
        
    }
    
}

extension SearchResultViewController {
    private func bindUI() {
        
    }
}

