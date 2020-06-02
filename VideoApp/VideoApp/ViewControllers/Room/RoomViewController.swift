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

import IGListDiffKit
import UIKit

class RoomViewController: UIViewController {
    @IBOutlet weak var disableMicButton: CircleToggleButton!
    @IBOutlet weak var disableCameraButton:  CircleToggleButton!
    @IBOutlet weak var leaveButton: UIButton!
    @IBOutlet weak var switchCameraButton: UIButton!
    @IBOutlet weak var roomNameLabel: UILabel!
    @IBOutlet weak var participantCollectionView: UICollectionView!
    @IBOutlet weak var mainVideoView: VideoView!
    @IBOutlet weak var mainIdentityLabel: UILabel!
    var viewModel: RoomViewModel!
    var statsViewController: StatsViewController!
    var application: UIApplication!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        participantCollectionView.dataSource = self
        participantCollectionView.delegate = self
        participantCollectionView.register(ParticipantCell.self)

        disableMicButton.didToggle = { [weak self] in self?.viewModel.isMicOn = !$0 }
        disableCameraButton.didToggle = { [weak self] in
            self?.viewModel.isCameraOn = !$0
            self?.updateView()
        }

        viewModel.delegate = self
        viewModel.connect()

        statsViewController.addAsSwipeableView(toParentViewController: self)

        updateView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        application.isIdleTimerDisabled = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        application.isIdleTimerDisabled = false
    }
    
    @IBAction func leaveButtonTapped(_ sender: Any) {
        viewModel.disconnect()
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func switchCameraButtonTapped(_ sender: Any) {
        viewModel.cameraPosition = viewModel.cameraPosition == .front ? .back : .front
    }
    
    private func updateView() {
        roomNameLabel.text = viewModel.data.roomName
        disableMicButton.isSelected = !viewModel.isMicOn
        disableCameraButton.isSelected = !viewModel.isCameraOn
        switchCameraButton.isEnabled = viewModel.isCameraOn
        let participant = viewModel.data.mainParticipant
        mainVideoView.configure(config: participant.videoConfig)
        mainIdentityLabel.text = participant.identity
    }
}

extension RoomViewController: RoomViewModelDelegate {
    func didConnect() {
        updateView()
    }
    
    func didFailToConnect(error: Error) {
        showError(error: error) { [weak self] in self?.navigationController?.popViewController(animated: true) }
    }
    
    func didDisconnect(error: Error?) {
        if let error = error {
            showError(error: error) { [weak self] in self?.navigationController?.popViewController(animated: true) }
        } else {
            navigationController?.popViewController(animated: true)
        }
    }

    func didUpdateList(diff: ListIndexSetResult) {
        participantCollectionView.performBatchUpdates(
            {
                participantCollectionView.insertItems(at: diff.inserts.indexPaths)
                participantCollectionView.deleteItems(at: diff.deletes.indexPaths)
                diff.moves.forEach { move in
                    participantCollectionView.moveItem(
                        at: IndexPath(item: move.from, section: 0),
                        to: IndexPath(item: move.to, section: 0)
                    )
                }
            },
            completion: nil
        )
    }

    func didUpdateParticipant(at index: Int) {
        guard let cell = participantCollectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? ParticipantCell else { return }
        
        cell.configure(participant: viewModel.data.participants[index])
    }
    
    func didUpdateMainParticipant() {
        updateView()
    }
}

extension RoomViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.data.participants.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ParticipantCell.identifier, for: indexPath) as! ParticipantCell
        cell.configure(participant: viewModel.data.participants[indexPath.item])
        return cell
    }
}

extension RoomViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.togglePin(at: indexPath.item)
    }
}
