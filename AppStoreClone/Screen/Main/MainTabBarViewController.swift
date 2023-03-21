//
//  MainTabBarViewController.swift
//  AppStoreClone
//
//  Created by yjc on 2023/03/18.
//

import UIKit

final class MainTabBarViewController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setViewControllers([self.createSearchViewController()], animated: true)
    }
    
    private func createSearchViewController() -> UIViewController {
        let viewModel = SearchViewModel()
        let viewController = SearchViewController.instantiate(withViewModel: viewModel)
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.navigationBar.prefersLargeTitles = true
        navigationController.tabBarItem.image = UIImage(systemName: "magnifyingglass")
        navigationController.tabBarItem.title = "검색"
        return navigationController
    }
}
