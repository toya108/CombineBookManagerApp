//
//  SettingsViewController.swift
//  BookManager-iOS
//
//  Created by TOUYA KAWANO on 2020/05/28.
//  Copyright © 2020 Toya Kawano. All rights reserved.
//

import UIKit
import Combine

/// 設定画面
final class SettingsViewController: UIViewController {
    
    // MARK: Properties
    
    private let viewModel = SettingsViewModel()
    private var binding = Set<AnyCancellable>()
    
    @IBOutlet weak var settingsNavigationBar: UINavigationBar!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    // MARK: IBActions
    
    @IBAction func logoutButtonTapped(_ sender: UIButton) {
        
        let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { [weak self] _ in
            
            guard let self = self else { return }
            
            self.viewModel.logout()
        })
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel)
        showAlert(title: NSLocalizedString("warning", comment: ""),
                  message: NSLocalizedString("logout_confirm_message", comment: ""),
                  actions: [okAction, cancelAction])
    }
    
    // MARK: Life Cycles

    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindViewModelToView()
    }
    
    // MARK: Private Functions
    
    private func bindViewModelToView() {
        let stateDidChangedHandler: (NetWorkState) -> Void = { [weak self] state in
            
            guard let self = self else { return }
            
            switch state {
            case .standby:
                break
                
            case .loading:
                self.loadingIndicator.startAnimating()
                
            case .finished:
                self.loadingIndicator.stopAnimating()
                
                let okAction: (UIAlertAction) -> Void = { _ in
                    guard let loginViewController = R.storyboard.login.instantiateInitialViewController() else { return }
                    
                    guard let currentKeyWindow =  UIApplication.shared.extractCurrentKeyWindow() else { return }
                    
                    currentKeyWindow.rootViewController = loginViewController
                }
                
                self.showOkAlert(title: NSLocalizedString("success", comment: ""),
                            message: NSLocalizedString("logout_success_message", comment: ""),
                            okActionHandler: okAction)

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
    
}

// MARK: - UINavigationBarDelegate

extension SettingsViewController: UINavigationBarDelegate {
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
}
