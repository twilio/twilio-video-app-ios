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

class EditTextViewController: UITableViewController {
    var viewModel: EditTextViewModel!
    var updateHandler: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = viewModel.title
        navigationItem.largeTitleDisplayMode = .never

        tableView.register(EditTextCell.self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        let cell = tableView.visibleCells.first as? EditTextCell
        cell?.textField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let cell = tableView.visibleCells.first as? EditTextCell
        cell?.textField.resignFirstResponder()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: EditTextCell.identifier) as! EditTextCell
        cell.textField.placeholder = viewModel.placeholder
        cell.textField.text = viewModel.text
        cell.textField.delegate = self
        cell.textField.keyboardType = viewModel.keyboardType
        return cell
    }
}

extension EditTextViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        viewModel.text = textField.text ?? ""
        updateHandler?()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        navigationController?.popViewController(animated: true)
        return true
    }
}
