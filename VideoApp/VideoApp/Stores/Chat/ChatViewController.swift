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

class ChatTokenStore {
    static let shared = ChatTokenStore()
    var token = ""
}

class ChatViewController: UITableViewController {
    private let chatStore = ChatStore()
    let dateFormatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        
        chatStore.delegate = self
        
        chatStore.start(token: ChatTokenStore.shared.token, uniqueName: "tcr amazing chat")
    }
    
    @IBAction func composeTap(_ sender: Any) {
        let alertController = UIAlertController(title: "New Message", message: nil, preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = "Message"
        }
        let confirmAction = UIAlertAction(title: "Send", style: .default) { [weak self, weak alertController] _ in
            guard let text = alertController?.textFields?.first?.text else { return }
            self?.chatStore.sendMessage(text)
        }
        alertController.addAction(confirmAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func doneTap(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        chatStore.messages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath)
        
        let message = chatStore.messages[indexPath.row]
        cell.textLabel?.text = message.body
        
        let date: String
        
        if let dateCreated = message.dateCreatedAsDate {
            date = dateFormatter.string(from: dateCreated)
        } else {
            date = ""
        }
        
        cell.detailTextLabel?.text = "\(message.author ?? "") sent \(date)"
        
        return cell
    }
}

extension ChatViewController: ChatStoreDelegate {
    func didJoinChat() {
        print("did join chat!")
        tableView.reloadData()
    }
    
    func didReceiveNewMessage() {
        tableView.reloadData()
    }
}
