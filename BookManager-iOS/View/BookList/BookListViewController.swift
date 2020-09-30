//
//  BookListViewController.swift
//  BookManager-iOS
//
//  Created by TOUYA KAWANO on 2020/05/28.
//  Copyright © 2020 Toya Kawano. All rights reserved.
//

import UIKit
import Combine

/// 書籍一覧画面
final class BookListViewController: UIViewController {
    
    // MARK: Properties
    
    private let viewModel = BookListViewModel()
    private var binding = Set<AnyCancellable>()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        return tableView
    }()
    
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        return indicator
    }()
    
    // MARK: Life Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupContentView()
        setupTableView()
        setupSubViews()
        setupBindings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        viewModel.resetData()
    }
    
    // MARK: Selectors
    
    @objc private func addButtonTapped(_sender: UIBarButtonItem) {
        let bookAddViewController = BookAddViewController()
        bookAddViewController.modalPresentationStyle = .fullScreen
        present(bookAddViewController, animated: true)
    }
    
    @objc private func scrollTop(_ sender: UITapGestureRecognizer) {
        tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
    }
    
    // MARK: Internal Functions
    
    /// テーブルビューの底まで達したことを検知したら次のページの書籍を取得しに行きます。
    /// - Parameter scrollView: スクロールビュー
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        guard tableView.isDragging else { return }
        
        let isReachedTableViewBottom = tableView.contentOffset.y + tableView.frame.size.height > tableView.contentSize.height
        
        guard isReachedTableViewBottom else { return }
        
        viewModel.fetchBookList()
    }
    
    // MARK: Private Functions
    
    /// NvigationBarをセットアップします。
    private func setupNavigationBar() {
        navigationItem.title = "書籍一覧"
        let recognnnizer = UITapGestureRecognizer(target: self, action: #selector(scrollTop(_:)))
        self.navigationController?.navigationBar.addGestureRecognizer(recognnnizer)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "追加",
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(addButtonTapped(_sender:)))
    }
    
    /// Viewをセットアップします。
    private func setupContentView() {
        view.backgroundColor = .systemBackground
    }
    
    /// TableViewをセットアップします。
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(BookRowTableViewCell.self)
        view.addSubview(tableView)
        tableView.fillSafeArea(safeArea: view.safeAreaLayoutGuide)
    }
    
    /// subViewをセットアップします。
    private func setupSubViews() {
        view.addSubview(loadingIndicator)
        loadingIndicator.center = view.center
    }
    
    /// データバインディングのセットアップをします。
    private func setupBindings() {
        
        func bindViewModelToView() {
            let stateDidChangedHandler: (NetWorkState) -> Void = { [weak self] state in
                
                guard let self = self else { return }
                
                switch state {
                case .standby:
                    break
                    
                case .loading:
                    self.loadingIndicator.startAnimating()
                    
                case .finished:
                    self.loadingIndicator.stopAnimating()
                    
                case .error(let error):
                    self.loadingIndicator.stopAnimating()
                    self.showOkAlert(title: NSLocalizedString("warning", comment: ""),
                                     message: error.localizedDescription,
                                     okActionHandler: { _ in self.viewModel.resetData() })
                }
            }
            
            viewModel.$networkState
                .receive(on: RunLoop.main)
                .sink(receiveValue: stateDidChangedHandler)
                .store(in: &binding)
            
            viewModel.$bookListResponnse
                .receive(on: RunLoop.main)
                .sink { [weak self] _ in
                    
                    guard let self = self else { return }
                    
                    self.tableView.reloadData() }
                .store(in: &binding)
        }
        
        bindViewModelToView()
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension BookListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.bookListResponnse.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(BookRowTableViewCell.self, for: indexPath)
        
        guard viewModel.bookListResponnse.indices.contains(indexPath.row) else {
            return UITableViewCell()
        }
        
        cell.setContents(book: viewModel.bookListResponnse[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // セルを選択した時のハイライトをフワッとさせるために用意しています。
        tableView.deselectRow(at: indexPath, animated: true)
        let bookResponse = viewModel.bookListResponnse[indexPath.row]
        
        guard let bookEditViewController = (R.storyboard.bookEdit().instantiateInitialViewController { coder in
            let book = Book(id: bookResponse.id,
                            name: bookResponse.name,
                            image: bookResponse.image,
                            price: bookResponse.price?.description,
                            purchaseDate: bookResponse.purchaseDate)
            // BookEditViewControllerのinitializerで書籍のデータを渡しています。
            return BookEditViewController(coder: coder, book: book)
        }) else {
            return
        }
        
        navigationController?.pushViewController(bookEditViewController, animated: true)
    }
}
