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

class SelectOptionViewController: UITableViewController {
    var viewModel: SelectOptionViewModel!
    var updateHandler: ((String) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = viewModel.title
        navigationItem.largeTitleDisplayMode = .never
        
        tableView.register(BasicCell.self)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.options.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: BasicCell.identifier)!
        cell.textLabel?.text = viewModel.options[indexPath.row]
        cell.accessoryType = viewModel.selectedIndex == indexPath.row ? .checkmark : .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.selectedIndex = indexPath.row
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.visibleCells.forEach { $0.accessoryType = .none }
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        updateHandler?(viewModel.options[indexPath.row])
    }
}
