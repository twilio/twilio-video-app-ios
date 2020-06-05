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

enum VideoCodec: String, SettingOptions {
    case h264
    case vp8
    case vp8SimulcastVGA
    case vp8SimulcastHD
    
    var title: String {
        switch self {
        case .h264: return "H.264"
        case .vp8: return "VP8"
        case .vp8SimulcastVGA: return "VP8 Simulcast VGA"
        case .vp8SimulcastHD: return "VP8 Simulcast HD"
        }
    }
}
