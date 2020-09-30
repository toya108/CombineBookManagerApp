//
//  SignUpViewController.swift
//  BookManager-iOS
//
//  Created by TOUYA KAWANO on 2020/05/28.
//  Copyright © 2020 Toya Kawano. All rights reserved.
//

import UIKit
import Combine

/// アカウント設定画面
final class SignUpViewController: UIViewController, HasTextFieldViewControllerProtocol {
    
    // MARK: Properties
    
    /// 監視対象のNotificationToken
    var observedTokens: [NotificationToken] = []
    
    @IBOutlet weak var signUpNavigationBar: UINavigationBar!
    @IBOutlet weak var mailAddressTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var signUpLoadingIndicator: UIActivityIndicatorView!
    
    private let viewModel = SignUpViewModel()
    private var binding = Set<AnyCancellable>()
    
    // MARK: LifeCycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        observedTokens.append(contentsOf: [keyboardWillHideToken, keyboardWillShowToken])
        
        setupBinding()
    }
    
    // MARK: IBActions
    
    @IBAction func closeButtonTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
        if viewModel.validateUser() {
            view.endEditing(true)
            
            viewModel.signUp()
        } else {
            showOkAlert(title: NSLocalizedString("warning", comment: ""),
                        message: generateErrorMessage(by: viewModel.extractSingUpValidationErrors()))
        }
    }
    
    // MARK: InternalFunctions
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }

    // MARK: PrivateFunctions
    
    /// ViewModelとのデータの紐付けを行います。
    private func setupBinding() {
        
        func bindViewToViewModel() {
            mailAddressTextField.textDidChangedPublisher
                .receive(on: RunLoop.main)
                .assign(to: \.mailAddress, on: viewModel)
                .store(in: &binding)
            
            passwordTextField.textDidChangedPublisher
                .receive(on: RunLoop.main)
                .assign(to: \.password, on: viewModel)
                .store(in: &binding)
            
            confirmPasswordTextField.textDidChangedPublisher
                .receive(on: RunLoop.main)
                .assign(to: \.confirmPassword, on: viewModel)
                .store(in: &binding)
        }

        
        func bindViewModelToView() {
            viewModel.$networkState.receive(on: RunLoop.main).sink(receiveValue: { [weak self] in
                
                guard let self = self else { return }
                
                switch $0 {
                case .finished:
                    self.signUpLoadingIndicator.stopAnimating()
                    
                    let okActionHandler: (UIAlertAction) -> Void = { _ in
                        
                        guard let currentKeyWindow =  UIApplication.shared.extractCurrentKeyWindow() else { return }
                        
                        currentKeyWindow.rootViewController = MainTabBarController()
                    }
                    
                    self.showOkAlert(title: NSLocalizedString("success", comment: ""),
                                message: NSLocalizedString("login_success_message", comment: ""),
                                okActionHandler: okActionHandler)
                    
                case .error(let error):
                    self.signUpLoadingIndicator.stopAnimating()
                    
                    self.showOkAlert(title: NSLocalizedString("alert", comment: ""),
                                     message: error.localizedDescription)
                    
                case .standby:
                    break
                    
                case .loading:
                    self.signUpLoadingIndicator.startAnimating()
                    
                }
            })
            .store(in: &binding)
        }
        
        bindViewModelToView()
        bindViewToViewModel()
    }
}

// MARK: - UITextFieldDelegate

extension SignUpViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let textFields = [mailAddressTextField, passwordTextField, confirmPasswordTextField]
        
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

// MARK: - UINavigationBarDelegate

extension SignUpViewController: UINavigationBarDelegate {
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
}
