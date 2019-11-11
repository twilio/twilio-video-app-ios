//
//  NetworkQualityIndicator.swift
//  VideoApp
//
//  Created by Ryan Payne on 4/16/19.
//  Copyright © 2019 Twilio, Inc. All rights reserved.
//

import UIKit
import TwilioVideo

@objc class NetworkQualityIndicator : NSObject {
    @objc class func networkQualityIndicatorImage(forLevel networkQualityLevel: NetworkQualityLevel) -> UIImage? {
        var imageName: String?

        switch networkQualityLevel {
        case .zero:
            imageName = "network-quality-level-0"
        case .one:
            imageName = "network-quality-level-1"
        case .two:
            imageName = "network-quality-level-2"
        case .three:
            imageName = "network-quality-level-3"
        case .four:
            imageName = "network-quality-level-4"
        case.five:
            imageName = "network-quality-level-5"
        case .unknown:
            break
        @unknown default:
            break
        }

        guard let indicatorImageName = imageName else {
            return nil
        }

        return UIImage(named: indicatorImageName)
    }
}
