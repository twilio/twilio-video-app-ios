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
