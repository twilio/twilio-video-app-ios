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
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = UIColor(named: "BackgroundStronger")
        
        addSubview(label)
        
        label.textColor = .white
        label.textAlignment = .center
    }
        
    override func didMoveToSuperview() {
        guard let superview = superview else { return }
        
        translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            leadingAnchor.constraint(equalTo: superview.leadingAnchor),
            trailingAnchor.constraint(equalTo: superview.trailingAnchor),
            topAnchor.constraint(equalTo: superview.topAnchor),
            bottomAnchor.constraint(equalTo: superview.bottomAnchor)
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
    
    func configure(particiipant: ParticipantViewModel) {
        label.text = particiipant.displayName
    }
}
