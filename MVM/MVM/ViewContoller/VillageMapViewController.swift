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
    var mapView: UICollectionView!
    var joystickView: UIView!
    var upButton: UIButton!
    var downButton: UIButton!
    var leftButton: UIButton!
    var rightButton: UIButton!
    
    var webRTCClient: WebRTCClient = WebRTCClient()

    var safeWidth: CGFloat!
    var safeHeight: CGFloat!
    var safeTop: CGFloat!
    var centerX: CGFloat!
    var centerY: CGFloat!
    
    var videoWidth: CGFloat!
    var videoHeight: CGFloat!
    
    var mute = false
    var frontcamera = true
    
    func initVideoView() {
        print("init video view")
        if localVideoView != nil {
            localVideoView.removeFromSuperview()
        }
        if remoteVideoView != nil {
            remoteVideoView.removeFromSuperview()
        }
        
        localVideoView = UIView(frame: CGRect(x: centerX-30-videoWidth, y: 0, width: videoWidth, height: videoHeight))
        remoteVideoView = UIView(frame: CGRect(x: centerX+30, y: 0, width: videoWidth, height: videoHeight))
        self.view.addSubview(localVideoView)
        self.view.addSubview(remoteVideoView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        safeWidth = villageMapView.safeAreaLayoutGuide.layoutFrame.width
        safeHeight = villageMapView.safeAreaLayoutGuide.layoutFrame.height
        safeTop = villageMapView.safeAreaInsets.top
        
        centerX = safeWidth/2
        centerY = safeTop + safeHeight/2
        
        // 가운데 village 정방형
        mapView = UICollectionView(frame: CGRect(x: 0, y: centerY - safeWidth/2, width: safeWidth, height: safeWidth), collectionViewLayout: UICollectionViewFlowLayout())
        mapView.delegate = self
        mapView.dataSource = self
        mapView.register(VillageMapCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        mapView.backgroundView = UIImageView(image: UIImage(named: "background.png"))
        self.view.addSubview(mapView)
        
        // 위에 왼쪽 local, 오른쪽 remote
//        let videoHeight = (safeHeight-safeWidth)/2
        videoHeight = centerY-safeWidth/2
        videoWidth = videoHeight*9/16
        self.initVideoView()
        
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
    
    override func viewWillAppear(_ animated: Bool) {
        if myVillage == nil {
            return
        }
        
        let villageRef = db.collection("villages").document(myVillage!.villageId!)
        villageRef.addSnapshotListener { [self] snapshot, error in
            print("village 받아오기")
            
            guard let document = snapshot else {
                print("Error fetching document: \(error!)")
                return
            }
            guard let data = document.data() else {
                print("Document data was empty.")
                return
            }
            
            if myVillage == nil {
                return
            }
            
            do {
                var jsonData = try JSONSerialization.data(withJSONObject: data)
                var instance = try JSONDecoder().decode(FireVillage.self, from: jsonData)
                
                myVillage = Village.init(villageId: myVillage!.villageId!, fireVillage: instance)
                
                if self.mapView != nil {
                    self.mapView.reloadData()
                }
            }
            catch {
                print(error)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.webRTCClient.delegate = self
    }
    
    @IBAction func villageExit(_ sender: Any) {
        let alert = UIAlertController(title: "빌리지를 나가시겠습니까?", message: "빌리지 입장 화면으로 이동합니다.", preferredStyle: UIAlertController.Style.alert)
        let yesAction = UIAlertAction(title: "Yes", style: .default) { (action) in
            
            let r = (myAvatar?.position[0])!
            let c = (myAvatar?.position[1])!
            
            // 미팅중이면 hangup
            if myAvatar?.isMeeting == true {
                for i in 0...3 {
                    let m = myVillage?.meetingRooms[i]
                    if (m?.caller?.position[0] == r && m?.caller?.position[1] == c) || (m?.callee?.position[0] == r && m?.callee?.position[1] == c) {
                        m?.hangUp(webRTCClient: self.webRTCClient)
                        break
                    }
                }
            }
            
            myVillage?.villageMap[r][c] = nil
            myVillage?.avatarNum! -= 1
            myVillage?.sendToFire(completion: {
                
            })
            myAvatar = nil
            myVillage = nil
            
            // village enter view로 이동
            self.navigationController?.popToRootViewController(animated: true)
        }
        let noAction = UIAlertAction(title: "NO", style: .cancel)
        alert.addAction(yesAction)
        alert.addAction(noAction)
        present(alert, animated: false, completion: nil)
    }
    
    
    @IBOutlet weak var micButton: UIButton!
    @IBAction func onoffMic(_ sender: Any) {
        if self.mute == true {
            self.mute = false
            micButton.setImage(UIImage(systemName: "mic"), for: .normal)
            self.webRTCClient.setAudioEnabled(true)
        }
        else {
            self.mute = true
            micButton.setImage(UIImage(systemName: "mic.slash"), for: .normal)
            self.webRTCClient.setAudioEnabled(false)
        }
    }
    @IBOutlet weak var cameraButton: UIButton!
    @IBAction func rotateCamera(_ sender: Any) {
        self.frontcamera = !self.frontcamera
        let localRenderer = RTCMTLVideoView(frame: CGRect(x: 0, y: 0, width: self.localVideoView.frame.width, height: self.localVideoView.frame.height))
        localRenderer.videoContentMode = .scaleAspectFill
        self.webRTCClient.startCaptureLocalVideo(renderer: localRenderer, front: self.frontcamera)
        self.localVideoView.addSubview(localRenderer)
        self.localVideoView.layoutIfNeeded()
    }
}

extension VillageMapViewContoller: WebRTCClientDelegate {
    func webRTCClient(_ client: WebRTCClient, didDiscoverLocalCandidate candidate: RTCIceCandidate) {
        print("did discover local candidate")
        client.sendCandidate(candidate: candidate)
    }
    
    func webRTCClient(_ client: WebRTCClient, didCreateLocalCapturer capturer: RTCCameraVideoCapturer) {
//        DispatchQueue.main.async {
//            print("did create local capturer -> local render")
//            let localRenderer = RTCMTLVideoView(frame: CGRect(x: 0, y: 0, width: self.localVideoView.frame.width, height: self.localVideoView.frame.height))
//            localRenderer.videoContentMode = .scaleAspectFill
//            client.startCaptureLocalVideo(renderer: localRenderer)
//            self.localVideoView.addSubview(localRenderer)
//            self.localVideoView.layoutIfNeeded()
//        }
    }
    
    func webRTCClient(_ client: WebRTCClient, didChangeSignaling stateChanged: RTCSignalingState) {
        DispatchQueue.main.async { [self] in
            if stateChanged.rawValue == 1 || stateChanged.rawValue == 3 { //  have local/remote offer
                print("signaling have offer -> local render")
                let localRenderer = RTCMTLVideoView(frame: CGRect(x: 0, y: 0, width: localVideoView.frame.width, height: localVideoView.frame.height))
                localRenderer.videoContentMode = .scaleAspectFill
                client.startCaptureLocalVideo(renderer: localRenderer, front: self.frontcamera)
                localVideoView.addSubview(localRenderer)
                localVideoView.layoutIfNeeded()
                
                micButton.isEnabled = true
                cameraButton.isEnabled = true
            }
        }
    }
    
    func webRTCClient(_ client: WebRTCClient, didChangeIceConnection newState: RTCIceConnectionState) {
        DispatchQueue.main.async { [self] in
            if newState.rawValue == 2 { // connected
                print("ice connection connected -> remote render")
                let remoteRenderer = RTCMTLVideoView(frame: CGRect(x: 0, y: 0, width: remoteVideoView.frame.width, height: remoteVideoView.frame.height))
                remoteRenderer.videoContentMode = .scaleAspectFill
                client.renderRemoteVideo(to: remoteRenderer)
                remoteVideoView.addSubview(remoteRenderer)
                remoteVideoView.layoutIfNeeded()
            }
            
            else if newState.rawValue == 4 || newState.rawValue == 5 || newState.rawValue == 6 { // failed, disconnected, closed
                initVideoView()
                
                
                micButton.isEnabled = false
                cameraButton.isEnabled = false
            }
        }
        
    }
    
    func webRTCClient(_ client: WebRTCClient, didAdd stream: RTCMediaStream) {
//        DispatchQueue.main.async {
//            print("did add stream -> remote render")
//            let remoteRenderer = RTCMTLVideoView(frame: CGRect(x: 0, y: 0, width: self.remoteVideoView.frame.width, height: self.remoteVideoView.frame.height))
//            remoteRenderer.videoContentMode = .scaleAspectFill
//            client.renderRemoteVideo(to: remoteRenderer)
//            self.remoteVideoView.addSubview(remoteRenderer)
//            self.remoteVideoView.layoutIfNeeded()
//        }
    }
    
}

// map collection
extension VillageMapViewContoller: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        25
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! VillageMapCollectionViewCell
        
        let row = indexPath.item/5
        let col = indexPath.item%5
        
        // 일단 초기화
        cell.backgroundImageView?.image = nil
        cell.avatarNicknameView?.text = nil
        cell.avatarFaceView?.image = nil
        cell.avatarTopView?.image = nil
        cell.avatarBottomView?.image = nil
        
        // meeting room position은 background 설정
        for pos in myVillage!.meetingRoomPositions {
            if pos.0.0 == row && pos.0.1 == col {
                if pos.1.0 == row && pos.1.1 == col+1 {
                    // 왼쪽 벤치
                    cell.backgroundImageView?.image = UIImage(named: "bench_left.png")
//                    print("left: (\(row),\(col))")
                }
                else if pos.1.0 == row+1 && pos.1.1 == col {
                    // 위쪽 벤치
                    cell.backgroundImageView?.image = UIImage(named: "bench_up.png")
//                    print("up: (\(row),\(col))")
                }
            }
            else if pos.1.0 == row && pos.1.1 == col {
                if pos.0.0 == row && pos.0.1 == col-1 {
                    // 오른쪽 벤치
                    cell.backgroundImageView?.image = UIImage(named: "bench_right.png")
//                    print("right: (\(row),\(col))")
                }
                else if pos.0.0 == row-1 && pos.1.1 == col {
                    // 아래쪽 벤치
                    cell.backgroundImageView?.image = UIImage(named: "bench_down.png")
//                    print("down: (\(row),\(col))")
                }
            }
        }
        
        // 아바타 있으면 그리기
        let avatar = myVillage?.villageMap[row][col]
        
        if avatar != nil {
            print("avatar: (\(row),\(col))")
            cell.avatarNicknameView?.text = avatar?.nickname
            cell.avatarFaceView?.image = UIImage(named: "face_"+String(avatar!.face!)+".png")
            cell.avatarTopView?.image = UIImage(named: "top_"+String(avatar!.topColor!)+".png")
            cell.avatarBottomView?.image = UIImage(named: "bottom_"+String(avatar!.bottomColor!)+".png")
        }

        return cell
    }
    
    
    // 위 아래 간격
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    // 옆 간격
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    // cell 사이즈( 옆 라인을 고려하여 설정 )
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let width = collectionView.frame.width/5
        let size = CGSize(width: width, height: width)
        return size
    }
}


// joystick
extension VillageMapViewContoller {
    @objc func moveButtonAction(_ sender: UIButton) {
        print("move button action: \(sender.tag)")
        myVillage?.moveAvatar(position: (myAvatar!.position[0]!, myAvatar!.position[1]!), direction: sender.tag, webrtcClient: self.webRTCClient, completion: {
            print("myAvatar: pos=\(myAvatar?.position), ismeeting=\(myAvatar?.isMeeting)")
//            self.mapView.reloadData()
        })
    }
}

extension UIButton {
    @objc func rotate(angle: CGFloat) {
        let radians = angle / 180.0 * CGFloat.pi
        let rotation = self.transform.rotated(by: radians);
        self.transform = rotation
    }
}
