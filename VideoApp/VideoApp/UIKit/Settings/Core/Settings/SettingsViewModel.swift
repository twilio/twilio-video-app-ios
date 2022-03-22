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

import Foundation

struct SettingsViewModelSection {
    enum Row {
        case destructiveButton(title: String, tapHandler: () -> Void)
        case editableText(title: String, text: String, viewModelFactory: EditTextViewModelFactory)
        case info(title: String, detail: String)
        case optionList(title: String, selectedOption: String, viewModelFactory: SelectOptionViewModelFactory)
        case push(title: String, viewControllerFactory: ViewControllerFactory)
        case toggle(title: String, isOn: Bool, updateHandler: (Bool) -> Void)
    }

    let rows: [Row]
}

protocol SettingsViewModel: AnyObject {
    var title: String { get }
    var sections: [SettingsViewModelSection] { get }
}

extension SettingsViewModel {
    func row(at indexPath: IndexPath) -> SettingsViewModelSection.Row {
        sections[indexPath.section].rows[indexPath.row]
    }
}
