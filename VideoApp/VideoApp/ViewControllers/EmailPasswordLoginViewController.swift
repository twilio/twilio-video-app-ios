//
//  EmailPasswordLoginViewController.swift
//  VideoApp
//
//  Created by Ryan Payne on 7/17/18.
//  Copyright © 2018 Twilio, Inc. All rights reserved.
//

import UIKit

class EmailPasswordLoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        emailTextField.addTarget(self, action: #selector(EmailPasswordLoginViewController.login(_:)), for: .editingDidEndOnExit)
        passwordTextField.addTarget(self, action: #selector(EmailPasswordLoginViewController.login(_:)), for: .editingDidEndOnExit)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        emailTextField.becomeFirstResponder()
    }

    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func login(_ sender: Any) {
        guard let emailAddress = emailTextField.text, emailAddress != "" else {
            emailTextField.becomeFirstResponder()
            return
        }

        guard let password = passwordTextField.text, password != "" else {
            passwordTextField.becomeFirstResponder()
            return
        }

        AuthStore.shared.signIn(email: emailAddress, password: password) { [weak self] error in
            guard let window = self?.view.window else { return }
            
            AuthFlow(window: window).didSignIn(error: error)
        }
    }
}

// MARK: UITextFieldDelegate
extension EmailPasswordLoginViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let text = textField.text else {
            return false
        }

        return text != ""
    }
}

