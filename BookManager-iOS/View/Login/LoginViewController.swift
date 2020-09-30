//
//  ViewController.swift
//  BookManager-iOS
//
//  Created by TOUYA KAWANO on 2020/05/22.
//  Copyright © 2020 Toya Kawano. All rights reserved.
//

import UIKit
import Combine

/// ログイン画面
final class LoginViewController: UIViewController, HasTextFieldViewControllerProtocol {
    
    // MARK: Properties
    
    /// 監視対象のNotificationToken
    var observedTokens: [NotificationToken] = []
    
    @IBOutlet weak var mailAddressTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginNavigationBar: UINavigationBar!
    @IBOutlet weak var loginLoadingIndicator: UIActivityIndicatorView!
    
    private let viewModel = LoginViewModel()
    private var binding = Set<AnyCancellable>()
    
    // MARK: LifeCycles
    override func viewDidLoad() {
        super.viewDidLoad()
        observedTokens.append(contentsOf: [keyboardWillShowToken, keyboardWillHideToken])
        
        setUpBindings()
    }
    
    // MARK: IBActions
    
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        if viewModel.validateUser() {
            view.endEditing(true)
            
            viewModel.login()
        } else {
            let errors = viewModel.extractLoginValidationErrors()
            showOkAlert(title: NSLocalizedString("warning", comment: ""),
                        message: generateErrorMessage(by: errors))
        }
    }
    
    @IBAction func signUpButtonTapped(_ sender: UIButton) {
        
        guard let signUpViewController = R.storyboard.signUp.instantiateInitialViewController() else { return }
        
        signUpViewController.modalPresentationStyle = .fullScreen
        present(signUpViewController, animated: true)
    }
    
    // MARK: InternalFunctions
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    // MARK: PrivateFunctions
    
    /// ViewModelとのデータの紐付けを行います。
    private func setUpBindings() {
        
        func bindViewToViewModel() {
            mailAddressTextField.textDidChangedPublisher
                .receive(on: RunLoop.main)
                .assign(to: \.mailAddress, on: viewModel)
                .store(in: &binding)
            
            passwordTextField.textDidChangedPublisher
                .receive(on: RunLoop.main)
                .assign(to: \.password, on: viewModel)
                .store(in: &binding)
        }
        
        func bindViewModelToView() {
            let stateDidChangedHandler: (NetWorkState) -> Void = { [weak self] state in
                
                guard let self = self else { return }
                
                switch state {
                case .finished:
                    self.loginLoadingIndicator.stopAnimating()
                    let okActionHandler: (UIAlertAction) -> Void = { _ in
                        
                        guard let currentKeyWindow =  UIApplication.shared.extractCurrentKeyWindow() else { return }
                        
                        currentKeyWindow.rootViewController = MainTabBarController()
                    }
                    
                    self.showOkAlert(title: NSLocalizedString("success", comment: ""),
                                message: NSLocalizedString("login_success_message", comment: ""),
                                okActionHandler: okActionHandler)
                    
                case .error(let error):
                    self.loginLoadingIndicator.stopAnimating()
                    
                    self.showOkAlert(title: NSLocalizedString("warning", comment: ""),
                                       message: error.localizedDescription)
                case .standby:
                    break
                    
                case .loading:
                    self.loginLoadingIndicator.startAnimating()
                    
                }
            }
            
            viewModel.$networkState
                .receive(on: RunLoop.main)
                .sink(receiveValue: stateDidChangedHandler)
                .store(in: &binding)
        }
        
        bindViewModelToView()
        bindViewToViewModel()
    }
}

// MARK: - UITextFieldDelegate

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let textFields = [mailAddressTextField, passwordTextField]
        
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

extension LoginViewController: UINavigationBarDelegate {
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
}
