//
//  PIPPlaceholderView.swift
//  VideoApp
//
//  Created by Tim Rozum on 8/25/22.
//  Copyright © 2022 Twilio, Inc. All rights reserved.
//

import UIKit

class PIPPlaceholderView: UIView {
    let label = UILabel()
    private var count = 0
    private var timer: Timer?
    
    required init?(coder aDecoder: NSCoder) {
        // This example does not support storyboards.
        assert(false, "Unsupported.")
        return nil
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .green
        
        addSubview(label)
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            self.count += 1
            self.label.text = "Hello \(self.count)"
        }
    }
        
    override func didMoveToSuperview() {
        guard let superview = superview else { return }
        
        translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            leadingAnchor.constraint(equalTo: superview.leadingAnchor),
            trailingAnchor.constraint(equalTo: superview.trailingAnchor),
            topAnchor.constraint(equalTo: superview.topAnchor),
            bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: -200)
        ]
        NSLayoutConstraint.activate(constraints)

        label.translatesAutoresizingMaskIntoConstraints = false
        let labelConstraints = [
            leadingAnchor.constraint(equalTo: label.leadingAnchor),
            trailingAnchor.constraint(equalTo: label.trailingAnchor),
            topAnchor.constraint(equalTo: label.topAnchor),
            bottomAnchor.constraint(equalTo: label.bottomAnchor)
        ]
        NSLayoutConstraint.activate(labelConstraints)
        

    }
}
