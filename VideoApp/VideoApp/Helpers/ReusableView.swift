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

// Inspired by https://medium.com/@gonzalezreal/ios-cell-registration-reusing-with-swift-protocol-extensions-and-generics-c5ac4fb5b75e

protocol ReusableView: AnyObject {
    static var defaultReuseIdentifier: String { get }
}

extension ReusableView {
    static var defaultReuseIdentifier: String {
        String(describing: self)
    }
}

extension UITableViewHeaderFooterView: ReusableView { }

extension UITableViewCell: ReusableView { }

extension UICollectionViewCell: ReusableView { }

protocol NibLoadableView: AnyObject {
    static var nibName: String { get }
}

extension NibLoadableView {
    static var nibName: String {
        String(describing: self)
    }
}

extension UITableView {
    func register<T: UITableViewHeaderFooterView>(_ headerFooterView: T.Type) where T: NibLoadableView {
        let bundle = Bundle(for: T.self)
        let nib = UINib(nibName: T.nibName, bundle: bundle)
        register(nib, forHeaderFooterViewReuseIdentifier: T.defaultReuseIdentifier)
    }
    
    func register<T: UITableViewCell>(_ cell: T.Type) where T: NibLoadableView {
        let bundle = Bundle(for: T.self)
        let nib = UINib(nibName: T.nibName, bundle: bundle)
        register(nib, forCellReuseIdentifier: T.defaultReuseIdentifier)
    }

    func dequeueReusableHeaderFooterView<T: UITableViewHeaderFooterView>() -> T {
        dequeueReusableHeaderFooterView(withIdentifier: T.defaultReuseIdentifier) as! T
    }

    func dequeueReusableCell<T: UITableViewCell>(for indexPath: IndexPath) -> T {
        dequeueReusableCell(withIdentifier: T.defaultReuseIdentifier, for: indexPath) as! T
    }
}

extension UICollectionView {
    func register<T: UICollectionViewCell>(_ cell: T.Type) where T: NibLoadableView {
        let bundle = Bundle(for: T.self)
        let nib = UINib(nibName: T.nibName, bundle: bundle)
        register(nib, forCellWithReuseIdentifier: T.defaultReuseIdentifier)
    }

    func dequeueReusableCell<T: UICollectionViewCell>(for indexPath: IndexPath) -> T {
        dequeueReusableCell(withReuseIdentifier: T.defaultReuseIdentifier, for: indexPath) as! T
    }
}
