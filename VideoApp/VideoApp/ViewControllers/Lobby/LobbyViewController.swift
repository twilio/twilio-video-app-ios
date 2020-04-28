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

import UIKit

class LobbyViewController: UIViewController {
    @IBOutlet weak var loggedInUser: UILabel!
    @IBOutlet weak var videoView: MainVideoView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var roomTextField: UITextField!
    @IBOutlet weak var audioToggleButton: UIButton!
    @IBOutlet weak var videoToggleButton: UIButton!
    @IBOutlet weak var flipCameraButton: UIButton!
    private let localParticipantFactory = LocalParticipantFactory()
    private let deepLinkStore: DeepLinkStoreWriting = DeepLinkStore.shared
    private let notificationCenter = NotificationCenter.default
    private var participant: LocalParticipant!

    override func viewDidLoad() {
        super.viewDidLoad()

        resetParticipant()
        configureVideoView()

        roomTextField.attributedPlaceholder = NSAttributedString(
            string: "Room",
            attributes: [.foregroundColor: UIColor.lightGray]
        )
        
        if let deepLink = deepLinkStore.consumeDeepLink() {
            switch deepLink {
            case let .room(roomName): roomTextField.text = roomName
            }
        }

        roomTextField .addTarget(self, action: #selector(joinRoomButtonPressed(_:)), for: .editingDidEndOnExit)
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        
        notificationCenter.addObserver(self, selector: #selector(participantDidChange(_:)), name: .participantUpdate, object: nil)
        notificationCenter.addObserver(self, selector: #selector(handleSettingChange), name: .appSettingDidChange, object: nil)
        
        refresh()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        configureVideoView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configureVideoView()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        let guide = view.safeAreaLayoutGuide
        let height = guide.layoutFrame.origin.y + 108
        containerView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: height)
    }

    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        
        view.setNeedsLayout()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "roomSegue":
            let roomViewController = segue.destination as! RoomViewController
            let room = RoomFactory().makeRoom(localParticipant: participant)
            roomViewController.viewModel = RoomViewModelFactory().makeRoomViewModel(
                roomName: roomTextField.text ?? "",
                room: room
            )
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let statsViewController = storyboard.instantiateViewController(withIdentifier: "statsViewController") as! StatsViewController
            statsViewController.videoAppRoom = room
            roomViewController.statsViewController = statsViewController
        case "showSettings":
            let navigationController = segue.destination as! UINavigationController
            let settingsViewController = navigationController.viewControllers.first as! SettingsViewController
            settingsViewController.viewModel = GeneralSettingsViewModel(
                appInfoStore: AppInfoStoreFactory().makeAppInfoStore(),
                appSettingsStore: AppSettingsStore.shared,
                authStore: AuthStore.shared,
                selectVideoCodecViewModelFactory: SelectVideoCodecViewModelFactory()
            )
        default:
            break
        }
    }
        
    @IBAction func toggleAudioPressed(_ sender: Any) {
        participant.isMicOn = !participant.isMicOn
        refresh()
    }
    
    @IBAction func toggleVideoPressed(_ sender: Any) {
        participant.isCameraOn = !participant.isCameraOn
        refresh()
    }
    
    @IBAction func flipCameraPressed(_ sender: Any) {
        participant.cameraPosition = participant.cameraPosition == .front ? .back : .front
    }
    
    @IBAction func joinRoomButtonPressed(_ sender: Any) {
        guard let roomName = roomTextField.text, !roomName.isEmpty else {
            roomTextField.becomeFirstResponder()
            return
        }
        
        dismissKeyboard()
        performSegue(withIdentifier: "roomSegue", sender: self)
    }
    
    private func resetParticipant() {
        participant = localParticipantFactory.makeLocalParticipant()
        participant.isMicOn = true
        participant.isCameraOn = true
    }
    
    @objc private func handleSettingChange() {
        resetParticipant() // Pick up settings like identity and video codec
        refresh()
    }

    @objc private func participantDidChange(_ notification: Notification) {
        guard let payload = notification.payload as? ParticipantUpdate else { return }
        
        switch payload {
        case let .didUpdate(participant):
            guard participant === participant else { return }

            configureVideoView()
        }
    }
    
    private func configureVideoView() {
        let isVisible = viewIfLoaded?.window != nil
        
        videoView.configure(
            identity: participant.identity,
            videoConfig: .init(
                videoTrack: isVisible ? participant.cameraTrack : nil,
                shouldMirror: participant.shouldMirrorCameraVideo
            )
        )
    }
    
    private func refresh() {
        loggedInUser.text = participant.identity
        audioToggleButton.isSelected = !participant.isMicOn
        videoToggleButton.isSelected = !participant.isCameraOn
        flipCameraButton.isEnabled = participant.isCameraOn
    }

    @objc private func dismissKeyboard() {
        roomTextField.resignFirstResponder()
    }
}
