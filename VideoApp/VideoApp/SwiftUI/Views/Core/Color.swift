//
//  Copyright (C) 2022 Twilio, Inc.
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

import SwiftUI

// Colors defined at https://paste.twilio.design/tokens/
extension Color {
    static var background: Color { Color("Background") }
    static var backgroundBodyInverse: Color { Color("BackgroundBodyInverse") }
    static var backgroundDestructive: Color { Color("BackgroundDestructive") }
    static var backgroundInverseStrong: Color { Color("BackgroundInverseStrong") }
    static var backgroundPrimary: Color { Color("BackgroundPrimary") }
    static var backgroundPrimaryWeak: Color { Color("BackgroundPrimaryWeak") }
    static var backgroundStrong: Color { Color("BackgroundStrong") }
    static var backgroundStronger: Color { Color("BackgroundStronger") }
    static var backgroundStrongest: Color { Color("BackgroundStrongest") }
    static var border: Color { Color("Border") }
    static var borderSuccessWeak: Color { Color("BorderSuccessWeak") }
    static var recordingDotBright: Color { Color("RecordingDotBright") }
    static var recordingDotDark: Color { Color("RecordingDotDark") }
    static var roomBackground: Color { backgroundBodyInverse }
}
