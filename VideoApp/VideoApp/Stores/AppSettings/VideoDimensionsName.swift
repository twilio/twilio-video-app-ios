//
//  Copyright (C) 2020 Twilio, Inc.
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

enum VideoDimensionsName: String, SettingOptions {
    case serverDefault
    case cif
    case vga
    case wvga
    case hd540P
    case hd720P
    case hd960P
    case hdStandard1080P
    case hdWidescreen1080P
    
    var title: String {
        switch self {
        case .serverDefault: return "Server Default"
        case .cif: return "352 x 288 (CIF)"
        case .vga: return "640 x 480 (VGA)"
        case .wvga: return "800 x 480 (WVGA)"
        case .hd540P: return "960 x 540 (540p HD)"
        case .hd720P: return "1280 x 720 (720p HD)"
        case .hd960P: return "1280 x 960 (960p HD)"
        case .hdStandard1080P: return "1440 x 1080 (Standard 1080p HD)"
        case .hdWidescreen1080P: return "1920 x 1080 (Widescreen 1080p HD)"
        }
    }
}
