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

class ChatViewController: UITableViewController {
    var viewModel: ChatViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.delegate = self
        viewModel.isUserReadingMessages = true
        
        tableView.register(
            UINib(nibName: "ChatHeaderView", bundle: nil),
            forHeaderFooterViewReuseIdentifier: "ChatHeaderView"
        )
        tableView.register(ChatMessageCell.self)
        tableView.sectionFooterHeight = 0
        tableView.sectionHeaderHeight = UITableView.automaticDimension;
        tableView.estimatedSectionHeaderHeight = 30;
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        viewModel.isUserReadingMessages = false
    }
    
    @IBAction func composeTap(_ sender: Any) {
        let alertController = UIAlertController(title: "New Message", message: nil, preferredStyle: .alert)

        alertController.addTextField { textField in
            textField.placeholder = "Message"
        }

        let sendAction = UIAlertAction(title: "Send", style: .default) { _ in
            guard let text = alertController.textFields?.first?.text else { return }
            
            ChatStore.shared.sendMessage(text) { error in
                guard let error = error else { return }

                print("Chat > Send message error:\n    \(error)")
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

    override func numberOfSections(in tableView: UITableView) -> Int {
        viewModel.numberOfSections()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfRowsInSection(section: section)
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "ChatHeaderView") as! ChatHeaderView

        headerView.configure(config: viewModel.configForSection(section: section))

        return headerView
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ChatMessageCell.identifier) as! ChatMessageCell

        cell.configure(config: viewModel.configForRow(indexPath: indexPath))
        
        return cell
    }
}

extension ChatViewController: ChatViewModelDelegate {
    func didReceiveNewMessage(indexPath: IndexPath) {
        // Disable all animations because .none didn't work which seems like an Apple bug
        UIView.setAnimationsEnabled(false)
        tableView.insertSections([indexPath.section], with: .none)
        UIView.setAnimationsEnabled(true)

        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }
}
