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

import Foundation

struct Transcription: Decodable {
    struct TranscriptionResponse: Decodable {
        struct TranscriptEvent: Decodable {
            struct Transcript: Decodable {
                struct Result: Decodable {
                    struct Alternative: Decodable {
                        let Transcript: String
                    }
                    
                    let ResultId: String
                    let ParticipantIdentity: String
                    let Alternatives: [Alternative]
                }
                
                let Results: [Result]
            }
            
            let Transcript: Transcript
        }
        
        let TranscriptEvent: TranscriptEvent
    }
    
    let transcriptionResponse: TranscriptionResponse
}
