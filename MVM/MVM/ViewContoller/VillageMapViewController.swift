//
//  VillageMapViewController.swift
//  MVM
//
//  Created by 이제인 on 2021/11/04.
//

import UIKit

import FirebaseFirestore
import WebRTC

class VillageMapViewContoller: UIViewController {
    
    @IBOutlet weak var cameraPreview: RTCCameraPreviewView!
    @IBOutlet weak var remoteVideoView: RTCEAGLVideoView!
    
    var webRTCClient: WebRTCClient = WebRTCClient()
    

    @IBOutlet weak var testbutton: UIButton!
    

    var meetingRoom: MeetingRoom = MeetingRoom.init()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.remoteVideoView.delegate = self
        self.webRTCClient.delegate = self
        
        self.meetingRoom.createRoom(webRTCClient: self.webRTCClient)
        
        print(self.meetingRoom)

    }
    
    @IBAction func testbuttonaction(_ sender: Any) {
        
        
        cameraPreview.captureSession = self.webRTCClient.videoCapturer?.captureSession
        self.webRTCClient.remoteVideoTrack?.add(self.remoteVideoView)
    }
    
    
    @IBAction func villageExit(_ sender: Any) {
        let alert = UIAlertController(title: "빌리지를 나가시겠습니까?", message: "빌리지 입장 화면으로 이동합니다.", preferredStyle: UIAlertController.Style.alert)
        let yesAction = UIAlertAction(title: "Yes", style: .default) { (action) in
            // village enter view로 이동
            self.performSegue(withIdentifier: "VillageExitSegue", sender: self)
        }
        let noAction = UIAlertAction(title: "NO", style: .cancel)
        alert.addAction(yesAction)
        alert.addAction(noAction)
        present(alert, animated: false, completion: nil)
    }
    
    
    func sendCandidate(candidate: RTCIceCandidate) {
        
        let candidatesCollection = meetingRoom.isRoomOpened ? db.collection("rooms").document().collection("calleeCandidates") : db.collection("rooms").document().collection("callerCandidates")
        
        do {
            let dataMessage = try JSONEncoder().encode(IceCandidate(from: candidate))
            let dict = try JSONSerialization.jsonObject(with: dataMessage, options: .allowFragments) as! [String: Any]
            candidatesCollection.addDocument(data: dict) { (err) in
                if let err = err {
                    print("Error send candidate: \(err)")
                }
                else {
                    print("Candidate sent!")
                }
            }
        }
        catch {
            print("JSONSericalization caller candidate fail")
        }
    }
}

extension VillageMapViewContoller: WebRTCClientDelegate {
    
    func webRTCClient(_ client: WebRTCClient, didDiscoverLocalCandidate candidate: RTCIceCandidate) {
        self.sendCandidate(candidate: candidate)
    }
}


extension VillageMapViewContoller: RTCVideoViewDelegate {
    
    func videoView(_ videoView: RTCVideoRenderer, didChangeVideoSize size: CGSize) {
        // videoView가 remote video view면 remove video view의 사이즈를 size로 한다
        remoteVideoView.setNeedsLayout()
    }
}
