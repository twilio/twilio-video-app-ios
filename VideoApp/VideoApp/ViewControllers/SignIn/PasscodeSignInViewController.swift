//
//  Copyright (C) 2020 Twilio, Inc.
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

class PasscodeSignInViewController: UIViewController {
    @IBOutlet weak var userIdentityTextField: UITextField!
    @IBOutlet weak var passcodeTextField: UITextField!
    var authFlowFactory: AuthFlowFactory = AuthFlowFactoryImpl()
    var authStore: AuthStoreWriting = AuthStore.shared
    
    // Validate input
    
    @IBAction func signInTap(_ sender: UIButton) {
        authStore.signIn(
            name: userIdentityTextField.text ?? "",
            passcode: passcodeTextField.text ?? ""
        ) { [weak self] error in
            guard let self = self, let window = self.view.window else { return }

            let authFlow = self.authFlowFactory.makeAuthFlow(window: window)
            authFlow.didSignIn(error: error)
        }
    }
}
