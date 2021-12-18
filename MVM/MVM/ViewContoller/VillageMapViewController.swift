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
    
    @IBOutlet var villageMapView: UIView!
    
    var localVideoView: UIView!
    var remoteVideoView: UIView!
    var villageView: UIView!
    var joystickView: UIView!
    var upButton: UIButton!
    var downButton: UIButton!
    var leftButton: UIButton!
    var rightButton: UIButton!
    
    var webRTCClient: WebRTCClient = WebRTCClient()
    var meetingRoom: MeetingRoom = MeetingRoom.init()

    
    override func viewDidAppear(_ animated: Bool) {
        let safeWidth = villageMapView.safeAreaLayoutGuide.layoutFrame.width
        let safeHeight = villageMapView.safeAreaLayoutGuide.layoutFrame.height
        let safeTop = villageMapView.safeAreaInsets.top
        
        let centerX = safeWidth/2
        let centerY = safeTop + safeHeight/2
        
        // 가운데 village 정방형
        villageView = UIView(frame: CGRect(x: 0, y: centerY - safeWidth/2, width: safeWidth, height: safeWidth))
        villageView.backgroundColor = UIColor.red
        self.view.addSubview(villageView)
        
        // 위에 왼쪽 local, 오른쪽 remote
//        let videoHeight = (safeHeight-safeWidth)/2
        let videoHeight = centerY-safeWidth/2
        let videoWidth = videoHeight*9/16
        localVideoView = UIView(frame: CGRect(x: centerX-30-videoWidth, y: 0, width: videoWidth, height: videoHeight))
        localVideoView.backgroundColor = UIColor.yellow
        remoteVideoView = UIView(frame: CGRect(x: centerX+30, y: 0, width: videoWidth, height: videoHeight))
        remoteVideoView.backgroundColor = UIColor.blue
        self.view.addSubview(localVideoView)
        self.view.addSubview(remoteVideoView)
        
        // 아래 왼쪽 조이스틱
        joystickView = UIView(frame: CGRect(x: centerX-150, y: safeTop+safeHeight-110, width: 90, height: 90))
        self.view.addSubview(joystickView)
        
        upButton = UIButton(frame: CGRect(x: 30, y: 0, width: 30, height: 30))
        upButton.setImage(UIImage(systemName: "play"), for: .normal)
        upButton.rotate(angle: 270)
        upButton.tag = 0
        upButton.addTarget(self, action: #selector(self.moveButtonAction(_:)), for: .touchUpInside)
        
        downButton = UIButton(frame: CGRect(x: 30, y: 60, width: 30, height: 30))
        downButton.setImage(UIImage(systemName: "play"), for: .normal)
        downButton.rotate(angle: 90)
        downButton.tag = 2
        downButton.addTarget(self, action: #selector(self.moveButtonAction(_:)), for: .touchUpInside)
        
        leftButton = UIButton(frame: CGRect(x: 0, y: 30, width: 30, height: 30))
        leftButton.setImage(UIImage(systemName: "play"), for: .normal)
        leftButton.rotate(angle: 180)
        leftButton.tag = 3
        leftButton.addTarget(self, action: #selector(self.moveButtonAction(_:)), for: .touchUpInside)
        
        rightButton = UIButton(frame: CGRect(x: 60, y: 30, width: 30, height: 30))
        rightButton.setImage(UIImage(systemName: "play"), for: .normal)
        rightButton.tag = 1
        rightButton.addTarget(self, action: #selector(self.moveButtonAction(_:)), for: .touchUpInside)
        
        joystickView.addSubview(upButton)
        joystickView.addSubview(downButton)
        joystickView.addSubview(leftButton)
        joystickView.addSubview(rightButton)
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.remoteVideoView.delegate = self
        self.webRTCClient.delegate = self
        
        var roomRef = self.meetingRoom.createRoom(webRTCClient: self.webRTCClient)
        self.webRTCClient.listenCallee(roomRef: roomRef)
        
//        print(self.meetingRoom)
    }
    
    
    
    @IBAction func testbuttonaction(_ sender: Any) {
        
        let localRenderer = RTCMTLVideoView(frame: CGRect(x: 0, y: 0, width: self.localVideoView.frame.width, height: self.localVideoView.frame.height))
//        let remoteRenderer = RTCMTLVideoView(frame: CGRect(x: 0, y: 0, width: self.remoteVideoView.frame.width, height: self.remoteVideoView.frame.height))
        
        localRenderer.videoContentMode = .scaleAspectFill
//        remoteRenderer.videoContentMode = .scaleAspectFill
        
        self.webRTCClient.startCaptureLocalVideo(renderer: localRenderer)
//        self.webRTCClient.renderRemoteVideo(to: remoteRenderer)
        
        self.localVideoView.addSubview(localRenderer)
//        self.remoteVideoView.addSubview(remoteRenderer)
        
        self.localVideoView.layoutIfNeeded()
//        self.remoteVideoView.layoutIfNeeded()
    }
    
    
    @IBAction func villageExit(_ sender: Any) {
        let alert = UIAlertController(title: "빌리지를 나가시겠습니까?", message: "빌리지 입장 화면으로 이동합니다.", preferredStyle: UIAlertController.Style.alert)
        let yesAction = UIAlertAction(title: "Yes", style: .default) { (action) in
            // village enter view로 이동
            self.navigationController?.popToRootViewController(animated: true)
        }
        let noAction = UIAlertAction(title: "NO", style: .cancel)
        alert.addAction(yesAction)
        alert.addAction(noAction)
        present(alert, animated: false, completion: nil)
    }
    
    
    func sendCandidate(candidate: RTCIceCandidate) {
        let candidatesCollection = meetingRoom.isRoomOpened! ? db.collection("rooms").document().collection("calleeCandidates") : db.collection("rooms").document().collection("callerCandidates")
        
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
        print("did discover local candidate")
        
        client.sendCandidate(candidate: candidate, isRoomOpened: self.meetingRoom.isRoomOpened!)
//        self.sendCandidate(candidate: candidate)
    }
}


// joystick
extension VillageMapViewContoller {
    @objc func moveButtonAction(_ sender: UIButton) {
        myAvatar?.requestMove(direction: sender.tag)
        
        let remoteRenderer = RTCMTLVideoView(frame: CGRect(x: 0, y: 0, width: self.remoteVideoView.frame.width, height: self.remoteVideoView.frame.height))
        
        remoteRenderer.videoContentMode = .scaleAspectFill
        
        self.webRTCClient.renderRemoteVideo(to: remoteRenderer)
        
        self.remoteVideoView.addSubview(remoteRenderer)
        self.remoteVideoView.layoutIfNeeded()
    }
}

extension UIButton {
    @objc func rotate(angle: CGFloat) {
        let radians = angle / 180.0 * CGFloat.pi
        let rotation = self.transform.rotated(by: radians);
        self.transform = rotation
    }
}
