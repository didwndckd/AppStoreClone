//
//  BaseViewController.swift
//  AppStoreClone
//
//  Created by yjc on 2023/03/18.
//

import UIKit

class BaseViewController: UIViewController {
    deinit {
        print("deinit -> \(type(of: self))")
    }
}
