//
//  Copyright (C) 2019 Twilio, Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
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
            
            AuthFlowFactoryImpl().makeAuthFlow(window: window).didSignIn(error: error)
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

