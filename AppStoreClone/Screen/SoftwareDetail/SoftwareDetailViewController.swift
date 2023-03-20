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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.bindUI()
    }
    
    private func setupUI() {
        
    }
    
}

extension SoftwareDetailViewController {
    private func bindUI() {
        
    }
}

