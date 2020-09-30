//
//  BookAddViewController.swift
//  BookManager-iOS
//
//  Created by TOUYA KAWANO on 2020/06/01.
//  Copyright © 2020 Toya Kawano. All rights reserved.
//

import UIKit
import Combine

/// 書籍追加画面
final class BookAddViewController: UIViewController, HasTextFieldViewControllerProtocol {
    
    /// 書籍追加画面の定数の構造体
    private struct Constant {
        static let bookImageViewleftConstant: CGFloat = 54
        static let bookImageViewHeightConstant: CGFloat = 120
        static let imageUploadButtonRightConstant: CGFloat = -54
        static let bookNameLabelTopConstant: CGFloat = 64
        static let bookTextFieldTopConstant: CGFloat = 8
        static let bookLabelTopConstant: CGFloat = 16
    }
    
    // MARK: Properties
    
    /// 監視対象のNotificationToken
    var observedTokens: [NotificationToken] = []
    private var viewModel = BookAddViewModel()
    private var binding = Set<AnyCancellable>()
    
    private lazy var bookAddNavigationBar: UINavigationBar = { [weak self] in
        let navigationBar = UINavigationBar()
        let navigationItem = UINavigationItem(title: NSLocalizedString("bookAdd", comment: ""))
        
        guard let self = self else { return navigationBar }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("save", comment: ""), style: .plain, target: self, action: #selector(saveButtonTapped(_:)))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: NSLocalizedString("close", comment: ""), style: .plain, target: self, action: #selector(closeButtonTapped(_:)))
        navigationBar.items = [navigationItem]
        
        return navigationBar
    }()
    
    private lazy var bookImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .gray
        return imageView
    }()
    
    private lazy var imageUploadButton: UIButton = {
        let button = UIButton()
        button.addTarget(nil, action: #selector(imageUploadButtonTapped(_:)), for: .touchUpInside)
        button.setTitle(NSLocalizedString("imageUploadButton", comment: ""), for: .normal)
        button.backgroundColor = .systemGray5
        button.setTitleColor(.systemBlue, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        return button
    }()
    
    private lazy var bookNameLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("bookName", comment: "")
        return label
    }()
    
    private lazy var bookNameTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        return textField
    }()
    
    private lazy var bookPriceLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("price", comment: "")
        return label
    }()
    
    private lazy var bookPriceTextField: UITextField = { [weak self] in
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.keyboardType = .numberPad
        return textField
    }()
    
    private lazy var bookPurchaseDateLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("purchaseDate", comment: "")
        return label
    }()
    
    private lazy var bookPurchaseDateTextField: UITextField = { [weak self] in
        
        let textField = UITextField()
        
        textField.borderStyle = .roundedRect
        textField.addTarget(nil, action: #selector(didBeganPurcahseDateTextFieldEditing(_:)), for: .editingDidBegin)
        
        guard let self = self else { return textField }
                                
        let doneToolBarButtons = [UIBarButtonItem(title: NSLocalizedString("done", comment: ""), style: .done, target: self, action: #selector(doneToolBarButtonTapped(_:)))]
        
        let toolBar = UIToolbar()
        toolBar.setItems(doneToolBarButtons, animated: true)
        toolBar.sizeToFit()
        textField.inputAccessoryView = toolBar
        
        return textField
    }()
    
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        return indicator
    }()
    
    // MARK: LifeCycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupContentView()
        setupSubViews()
        setUpBindings()
        
        observedTokens.append(contentsOf: [keyboardWillHideToken, keyboardWillShowToken])
    }
    
    // MARK: Internal Functions
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    // MARK: Selectors
    
    @objc private func saveButtonTapped(_ sender: UIBarButtonItem) {
        if viewModel.validateBook() {
            viewModel.bookAdd()
        } else {
            showOkAlert(title: NSLocalizedString("warning", comment: ""),
                        message: generateErrorMessage(by: viewModel.extractBookEditValidationErrors()))
        }
    }
    
    @objc private func closeButtonTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
    @objc private func doneToolBarButtonTapped(_ sender: UIBarButtonItem) {
        bookPurchaseDateTextField.resignFirstResponder()
    }
    
    @objc private func imageUploadButtonTapped(_ sender: UIButton) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        present(imagePickerController, animated: true)
    }
    
    @objc private func didBeganPurcahseDateTextFieldEditing(_ sender: UITextField) {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.locale = Locale(identifier: LocaleIdentifier.jp.rawValue)
        datePicker.calendar = Calendar(identifier: .gregorian)
        sender.inputView = datePicker
        datePicker.addTarget(nil, action: #selector(didChangedDatePickerValue(_:)), for: .valueChanged)
    }
    
    @objc private func didChangedDatePickerValue(_ sender: UIDatePicker) {
        bookPurchaseDateTextField.text = sender.date.convertString()
    }
}

// MARK: - SetUp

extension BookAddViewController {
    /// ContentViewのセットアップを行います。
    private func setupContentView() {
        view.backgroundColor = .systemBackground
    }
    
    /// SubViewのLayoutのセットアップを行います。
    private func setupSubViews() {
        addSubViews()
        addConstraints()
        
        bookAddNavigationBar.delegate = self
        [bookNameTextField, bookPriceTextField, bookPurchaseDateTextField].forEach { $0.delegate = self }
    }
    
    
    /// ViewにSubViewをセットします。
    private func addSubViews() {
        [bookAddNavigationBar, bookImageView, imageUploadButton, bookNameLabel, bookNameTextField, bookPriceLabel, bookPriceTextField, bookPurchaseDateLabel, bookPurchaseDateTextField, loadingIndicator].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    /// 制約を追加します。
    private func addConstraints() {
        
        let bookAddNavigationBarConstraints = [
            bookAddNavigationBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            bookAddNavigationBar.leftAnchor.constraint(equalTo: view.leftAnchor),
            bookAddNavigationBar.rightAnchor.constraint(equalTo: view.rightAnchor)
        ]
        
        let bookImageViewConstraints = [
            // anchorだとmultiplier指定のcenterY制約がなぜか生成できないのでここだけNSLayoutConstraintを直に生成しています。
            NSLayoutConstraint(item: bookImageView, attribute: .centerY, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .centerY, multiplier: 0.5, constant: 1),
            bookImageView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: Constant.bookImageViewleftConstant),
            bookImageView.heightAnchor.constraint(equalToConstant: Constant.bookImageViewHeightConstant),
            bookImageView.widthAnchor.constraint(equalTo: bookImageView.heightAnchor)
        ]

        let imageUploadButtonConstraints = [
            imageUploadButton.centerYAnchor.constraint(equalTo: bookImageView.centerYAnchor),
            imageUploadButton.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: Constant.imageUploadButtonRightConstant)
        ]
        
        let bookNameLabelCostraints = [
            bookNameLabel.topAnchor.constraint(equalTo: bookImageView.bottomAnchor, constant: Constant.bookNameLabelTopConstant),
            bookNameLabel.leftAnchor.constraint(equalTo: bookImageView.leftAnchor)
        ]
        
        let bookNameTextFieldConstrains = [
            bookNameTextField.topAnchor.constraint(equalTo: bookNameLabel.bottomAnchor, constant: Constant.bookTextFieldTopConstant),
            bookNameTextField.leftAnchor.constraint(equalTo: bookImageView.leftAnchor),
            bookNameTextField.rightAnchor.constraint(equalTo: imageUploadButton.rightAnchor)
        ]
        
        let bookPriceLabelConstraints = [
            bookPriceLabel.topAnchor.constraint(equalTo: bookNameTextField.bottomAnchor, constant: Constant.bookLabelTopConstant),
            bookPriceLabel.leftAnchor.constraint(equalTo: bookImageView.leftAnchor)
        ]
        
        let bookPriceTextFieldConstraints = [
            bookPriceTextField.topAnchor.constraint(equalTo: bookPriceLabel.bottomAnchor, constant: Constant.bookTextFieldTopConstant),
            bookPriceTextField.leftAnchor.constraint(equalTo: bookImageView.leftAnchor),
            bookPriceTextField.rightAnchor.constraint(equalTo: imageUploadButton.rightAnchor)
        ]
        
        let bookPurchaseDateLabelConstrains = [
            bookPurchaseDateLabel.topAnchor.constraint(equalTo: bookPriceTextField.bottomAnchor, constant: Constant.bookLabelTopConstant),
            bookPurchaseDateLabel.leftAnchor.constraint(equalTo: bookImageView.leftAnchor)
        ]
        
        let bookPurchaseDateTextFieldConstraints = [
            bookPurchaseDateTextField.topAnchor.constraint(equalTo: bookPurchaseDateLabel.bottomAnchor, constant: Constant.bookTextFieldTopConstant),
            bookPurchaseDateTextField.leftAnchor.constraint(equalTo: bookImageView.leftAnchor),
            bookPurchaseDateTextField.rightAnchor.constraint(equalTo: imageUploadButton.rightAnchor)
        ]
        
        let loadingIndicatorConstrains = [
            loadingIndicator.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)
        ]
        
        [bookAddNavigationBarConstraints, bookImageViewConstraints, imageUploadButtonConstraints, bookNameLabelCostraints, bookNameTextFieldConstrains, bookPriceLabelConstraints, bookPriceTextFieldConstraints, bookPurchaseDateLabelConstrains, bookPurchaseDateTextFieldConstraints, loadingIndicatorConstrains]
            .forEach(NSLayoutConstraint.activate(_:))
    }
    
    /// ViewModelとのデータの紐付けを行います。
    private func setUpBindings() {
        func setupViewToViewModel() {
            bookImageView.base64ImagePublisher
                .receive(on: RunLoop.main)
                .sink(receiveValue: { [unowned self] in
                    self.viewModel.book.image = $0
                })
                .store(in: &binding)
            
            bookNameTextField.textDidChangedPublisher
                .receive(on: RunLoop.main)
                .sink(receiveValue: { [unowned self] in
                    self.viewModel.book.name = $0
                })
                .store(in: &binding)
            
            bookPriceTextField.textDidChangedPublisher
                .receive(on: RunLoop.main)
                .sink(receiveValue: { [unowned self] in
                    self.viewModel.book.price = $0
                })
                .store(in: &binding)
            
            bookPurchaseDateTextField.endEditingPublisher
                .receive(on: RunLoop.main)
                .sink(receiveValue: { [unowned self] in
                    self.viewModel.book.purchaseDate = $0
                })
                .store(in: &binding)
        }
        
        func setupViewModelToView() {
            let stateDidChangedHandler: (NetWorkState) -> Void = { [weak self] state in
                
                guard let self = self else { return }
                
                switch state {
                case .standby:
                    break
                    
                case .loading:
                    self.loadingIndicator.startAnimating()
                    
                case .finished:
                    self.loadingIndicator.stopAnimating()
                    
                    let okActionHandler: (UIAlertAction) -> Void = { [weak self] _ in
                        
                        guard let self = self else { return }
                        
                        self.dismiss(animated: true)
                    }
                    
                    self.showOkAlert(title: NSLocalizedString("success", comment: ""),
                                message: NSLocalizedString("book_add_success_message", comment: ""),
                                okActionHandler: okActionHandler)
                    
                case .error(let error):
                    self.loadingIndicator.stopAnimating()
                    
                    self.showOkAlert(title: NSLocalizedString("warning", comment: ""),
                                       message: error.localizedDescription)
                }
            }
            
            viewModel.$networkState
                .receive(on: RunLoop.main)
                .sink(receiveValue: stateDidChangedHandler)
                .store(in: &binding)
        }
        
        setupViewModelToView()
        setupViewToViewModel()
    }
}

// MARK: - UITextFieldDelegate

extension BookAddViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let textFields = [bookNameTextField, bookPriceTextField, bookPurchaseDateTextField]
        
        guard let currentTextFieldIndex = textFields.firstIndex(of: textField) else { return false }
        
        // 次のTextFieldがあればressponderを移す。なければresponderを外す。
        if currentTextFieldIndex + 1 == textFields.endIndex {
            textField.resignFirstResponder()
        } else {
            textFields[currentTextFieldIndex + 1].becomeFirstResponder()
        }
        return true
    }
}

// MARK: - UINavigationBarDelegate

extension BookAddViewController: UINavigationBarDelegate {
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
}

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate

extension BookAddViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if case let pickedImage as UIImage = info[.originalImage] {
            bookImageView.image = pickedImage
            NotificationCenter.default.post(name: .didSetImageIntoImageView,
                                            object: nil,
                                            userInfo: ["base64Image": pickedImage.convertBase64String()])
        }
        dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
}
