//
//  Copyright (C) 2021 Twilio, Inc.
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

class ChatViewController: UIViewController {
    private let chatStore: ChatStoreWriting = ChatStore.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("Messages: \(chatStore.messages)")
    }
    
    @IBAction func composeTap(_ sender: Any) {
        let alertController = UIAlertController(title: "New Message", message: nil, preferredStyle: .alert)

        alertController.addTextField { textField in
            textField.placeholder = "Message"
        }

        let sendAction = UIAlertAction(title: "Send", style: .default) { [weak self] _ in
            guard let text = alertController.textFields?.first?.text else { return }
            
            self?.chatStore.sendMessage(text) { error in
                guard let error = error else { return }

                print("Send error: \(error)")
            }
        }

        alertController.addAction(sendAction)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)

        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func doneTap(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
