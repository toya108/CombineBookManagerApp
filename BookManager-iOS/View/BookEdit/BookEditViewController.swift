//
//  BookEditViewController.swift
//  BookManager-iOS
//
//  Created by TOUYA KAWANO on 2020/05/29.
//  Copyright © 2020 Toya Kawano. All rights reserved.
//

import UIKit
import Nuke
import Combine

/// 書籍編集画面
final class BookEditViewController: UIViewController, HasTextFieldViewControllerProtocol {
    
    // MARK: Properties
    
    /// 監視対象のNotificationToken
    lazy var observedTokens: [NotificationToken] = []
    
    /// 更新する書籍のデータ
    private var viewModel: BookEditViewModel
    private var binding = Set<AnyCancellable>()
    
    @IBOutlet weak var bookImageView: UIImageView!
    @IBOutlet weak var bookNameTextField: UITextField! {
        didSet {
            bookNameTextField.text = viewModel.book.name
        }
    }
    @IBOutlet weak var bookPriceTextField: UITextField! {
        didSet {
            bookPriceTextField.text = viewModel.book.price
        }
    }
    @IBOutlet weak var bookPurchaseDateTextField: UITextField! {
        didSet {
            let toolBar = UIToolbar()
            toolBar.sizeToFit()
            let doneToolBarButtons = [UIBarButtonItem(title: NSLocalizedString("done", comment: ""), style: .done, target: nil, action: #selector(doneToolBarButtonTapped(_:)))]
            toolBar.setItems(doneToolBarButtons, animated: true)
            bookPurchaseDateTextField.inputAccessoryView = toolBar
            
            bookPurchaseDateTextField.text = viewModel.book.purchaseDate
        }
    }
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    // MARK: Initializer
    
    init?(coder: NSCoder, book: Book) {
        self.viewModel = BookEditViewModel(book: book)
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: LifeCycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setUpBindings()
        setupInitialImage()
        
        observedTokens.append(contentsOf: [keyboardWillShowToken, keyboardWillHideToken])
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    // MARK: IBActions
    
    @IBAction private func imageUploadButtonTapped(_ sender: UIButton) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        present(imagePickerController, animated: true)
    }
    
    @IBAction private func didBeganPurcahseDateTextFieldEditing(_ sender: UITextField) {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.locale = Locale(identifier: LocaleIdentifier.jp.rawValue)
        datePicker.calendar = Calendar(identifier: .gregorian)
        sender.inputView = datePicker
        datePicker.addTarget(nil, action: #selector(didChangedDatePickerValue(_:)), for: .valueChanged)
    }
    
    // MARK: Selectors
    
    @objc private func saveButtonTapped(_ sender: UIBarButtonItem) {
        if viewModel.validateBook() {
            viewModel.bookEdit()
        } else {
            showOkAlert(title: NSLocalizedString("warning", comment: ""),
                        message: generateErrorMessage(by: viewModel.extractBookEditValidationErrors()))
        }
    }
    
    @objc private func didChangedDatePickerValue(_ sender: UIDatePicker) {
        bookPurchaseDateTextField.text = sender.date.convertString()
    }
    
    @objc private func doneToolBarButtonTapped(_ sender: UIBarButtonItem) {
        bookPurchaseDateTextField.resignFirstResponder()
    }
    
    // MARK: PrivateFunctions
    
    /// NavigationBarのセットアップを行います。
    private func setupNavigationBar() {
        navigationItem.title = NSLocalizedString("bookEdit", comment: "")
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("save", comment: ""), style: .plain, target: self,
                                                            action: #selector(saveButtonTapped(_:)))
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
                        
                        self.navigationController?.popViewController(animated: true)
                    }
                    
                    self.showOkAlert(title: NSLocalizedString("success", comment: ""),
                                     message: NSLocalizedString("book_edit_success_message", comment: ""),
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
    
    /// 初期画像をセットします。
    /// - note: 画像のロードと同時にbase64文字列をNotificationCenterでpostしています。
    /// 　　　　　bookImageViewのPublisherで通知を受け取りたいのでsetupBindingsが呼ばれてから実行してください。
    private func setupInitialImage() {
        if let imageUrl = viewModel.book.image {
            NukeManager.loadImageWithNotificationPost(with: imageUrl, imageView: bookImageView)
        }
    }
}

// MARK: - UITextFieldDelegate

extension BookEditViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let textFields = [bookNameTextField, bookPriceTextField, bookPurchaseDateTextField]
        
        guard let currentTextFieldIndex = textFields.firstIndex(of: textField) else { return false }
        
        // 次のTextFieldがあればressponderを移す。なければresponderを外す。
        if currentTextFieldIndex + 1 == textFields.endIndex {
            textField.resignFirstResponder()
        } else {
            textFields[currentTextFieldIndex + 1]?.becomeFirstResponder()
        }
        return true
    }
}

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate

extension BookEditViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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
