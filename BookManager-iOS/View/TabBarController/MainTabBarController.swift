//
//  MainTabBarController.swift
//  BookManager-iOS
//
//  Created by TOUYA KAWANO on 2020/05/28.
//  Copyright © 2020 Toya Kawano. All rights reserved.
//

import UIKit

/// 書籍管理用メインタブバーコントローラー
final class MainTabBarController: UITabBarController {

    // MARK: LifeCycles

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let bookListViewController = BookListViewController()
        let bookListNavigationController = UINavigationController(rootViewController: bookListViewController)
        bookListNavigationController.tabBarItem = UITabBarItem(title: NSLocalizedString("bookList", comment: ""), image: UIImage(systemName: "book"), tag: 1)
        
        guard let settingsViewController = R.storyboard.settings.instantiateInitialViewController() else { return }
        settingsViewController.tabBarItem = UITabBarItem(title: NSLocalizedString("settings", comment: ""), image: UIImage(systemName: "gear"), tag: 2)
        
        setViewControllers([bookListNavigationController, settingsViewController], animated: true)
    }
}
