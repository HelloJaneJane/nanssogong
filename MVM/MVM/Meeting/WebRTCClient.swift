//
//  WebRTCClient.swift
//  MVM
//
//  Created by 이제인 on 2021/12/06.
//

import Foundation
import WebRTC
import FirebaseFirestore

let kARDMedaiStreamId = "ARDAMS"
let kARDAudioTrackId = "ARDAMSa0"
let kARDVideoTrackId = "ARDAMSv0"
let kARDVideoTrackKind = "video"


// encoding, decoding 하기 위해 새로 codable struct 만듦 (RTCIceCandidate, RTCSdpType, RTCSessionDescription은 decodable)
struct IceCandidate: Codable {
    let sdp: String
    let sdpMLineIndex: Int32
    let sdpMid: String?
    
    init(from iceCandidate: RTCIceCandidate) {
        self.sdpMLineIndex = iceCandidate.sdpMLineIndex
        self.sdpMid = iceCandidate.sdpMid
        self.sdp = iceCandidate.sdp
    }
    
    var rtcIceCandidate: RTCIceCandidate {
        return RTCIceCandidate(sdp: self.sdp, sdpMLineIndex: self.sdpMLineIndex, sdpMid: self.sdpMid)
    }
}

struct SessionDescription: Codable {
    enum SdpType: String, Codable {
        case offer, answer, prAnswer
        
        var rtcSdpType: RTCSdpType {
            switch self {
            case .offer:    return .offer
            case .answer:   return .answer
            case .prAnswer: return .prAnswer
            }
        }
    }

    let sdp: String
    let type: SdpType
    
    init(from rtcSessionDescription: RTCSessionDescription) {
        self.sdp = rtcSessionDescription.sdp
        switch rtcSessionDescription.type {
            case .offer:    self.type = .offer
            case .prAnswer: self.type = .prAnswer
            case .answer:   self.type = .answer
            @unknown default:
                fatalError("Unknown RTCSessionDescription type: \(rtcSessionDescription.type.rawValue)")
        }
    }
    
    var rtcSessionDescription: RTCSessionDescription {
        return RTCSessionDescription(type: self.type.rtcSdpType, sdp: self.sdp)
    }
}

protocol WebRTCClientDelegate: AnyObject {
    func webRTCClient(_ client: WebRTCClient, didDiscoverLocalCandidate candidate: RTCIceCandidate)
}

class WebRTCClient: NSObject {
    
    weak var delegate: WebRTCClientDelegate?
    
    static let factory: RTCPeerConnectionFactory = {
        RTCInitializeSSL()
        let videoEncoderFactory = RTCDefaultVideoEncoderFactory()
        let videoDecoderFactory = RTCDefaultVideoDecoderFactory()
        return RTCPeerConnectionFactory(encoderFactory: videoEncoderFactory, decoderFactory: videoDecoderFactory)
    }()
    
    var peerConnection: RTCPeerConnection?
    let rtcAudioSession =  RTCAudioSession.sharedInstance()
    let audioQueue = DispatchQueue(label: "audio")
    let mediaConstrains = [kRTCMediaConstraintsOfferToReceiveAudio: kRTCMediaConstraintsValueTrue,
                           kRTCMediaConstraintsOfferToReceiveVideo: kRTCMediaConstraintsValueTrue]
//    var videoCapturer: RTCVideoCapturer?
    var videoCapturer: RTCCameraVideoCapturer?
    var localVideoTrack: RTCVideoTrack?
    var remoteVideoTrack: RTCVideoTrack?
    var iceServers: [String] = ["stun:stun1.l.google.com:19302","stun:stun2.l.google.com:19302"]
    
    var roomId: String?

    func createPeerConnection() {
        print("create peer connection")
        let rtcConfiguration = RTCConfiguration.init()
        rtcConfiguration.iceServers = [RTCIceServer.init(urlStrings: iceServers)]
        rtcConfiguration.iceCandidatePoolSize = 10

        let rtcMediaConstraints = RTCMediaConstraints.init(mandatoryConstraints: nil, optionalConstraints: ["DtlsSrtpKeyAgreement":"true"])
        
        self.peerConnection = WebRTCClient.factory.peerConnection(with: rtcConfiguration, constraints: rtcMediaConstraints, delegate: self)
        
        print(self.peerConnection)
        self.createMediaSenders()
        self.configureAudioSession()
    }
    
    func closePeerConnection() {
        self.peerConnection!.close()
        self.peerConnection = nil
    }
    
    func createMediaSenders() {
        print("create media senders")
        var audioConstraints = RTCMediaConstraints.init(mandatoryConstraints: [:], optionalConstraints: nil)
        var audioSource = WebRTCClient.factory.audioSource(with: audioConstraints)
        var audioTrack = WebRTCClient.factory.audioTrack(with: audioSource, trackId: kARDAudioTrackId)
        self.peerConnection!.add(audioTrack, streamIds: [kARDMedaiStreamId])
        
        var videoSource = WebRTCClient.factory.videoSource()
        
//        #if TARGET_OS_SIMULATOR
//        self.videoCapturer = RTCFileVideoCapturer(delegate: videoSource)
//        #else
        self.videoCapturer = RTCCameraVideoCapturer(delegate: videoSource)
//        #endif
        
        var localVideoTrack = WebRTCClient.factory.videoTrack(with: videoSource, trackId: kARDVideoTrackId)
        self.localVideoTrack = localVideoTrack
        self.peerConnection!.add(localVideoTrack, streamIds: [kARDMedaiStreamId])
        
//        var videoTransceiver: WebRTC.RTCRtpTransceiver? = nil
//        for transceiver in self.peerConnection!.transceivers {
//            if (transceiver.mediaType == RTCRtpMediaType.video) {
//                videoTransceiver = transceiver
//                break
//            }
//        }
//        self.remoteVideoTrack = videoTransceiver?.receiver.track as? RTCVideoTrack
        print("????????")
        
//        self.remoteVideoTrack = self.peerConnection!.transceivers.first { $0.mediaType == .video }?.receiver.track as? RTCVideoTrack
    }
    
    func configureAudioSession() {
        print("configure audio session")
        self.rtcAudioSession.lockForConfiguration()
        do {
            try self.rtcAudioSession.setCategory(AVAudioSession.Category.playAndRecord.rawValue)
            try self.rtcAudioSession.setMode(AVAudioSession.Mode.voiceChat.rawValue)
        }
        catch let error {
            print("Error changing AVAudioSession category: \(error)")
        }
        self.rtcAudioSession.unlockForConfiguration()
    }
    
    func createOffer(roomRef: DocumentReference, completion: @escaping (_ sdp: RTCSessionDescription) -> Void) {
        print("create offer")
//        let roomRef = db.collection("rooms").document()
        print(roomRef)
        
        self.peerConnection!.offer(for: RTCMediaConstraints(mandatoryConstraints: self.mediaConstrains, optionalConstraints: nil),
                                      completionHandler: { (sdp, error) in
            guard let sdp = sdp else {
                return
            }
//            self.peerConnection!.setLocalDescription(sdp)
            self.peerConnection!.setLocalDescription(sdp, completionHandler: {
                (error) in completion(sdp)
            })
            
            let roomWithOffer = ["offer": ["type": sdp.type.rawValue, "sdp": sdp.sdp]]
//            print(roomWithOffer)
            
            print(roomRef.documentID)
            
            roomRef.setData(roomWithOffer, completion: {
                (err) in
                    print("!!!!!!!!!!!")
                    if let err = err {
                        print("Error send offer sdp: \(err)")
                    }
                    else {
                        print("New room created with SDP offer. Room ID: \(roomRef.documentID)")
                        self.roomId = roomRef.documentID
                    }
            })
            
            print(db.collection("rooms"))
            
//            db.collection("rooms").addDocument(data: roomWithOffer) { (err) in
//                print("!!!!!!!!!!!")
//                if let err = err {
//                    print("Error send offer sdp: \(err)")
//                }
//                else {
//                    print("New room created with SDP offer. Room ID: \(roomRef.documentID)")
//                    self.roomId = roomRef.documentID
//                }
//            }
            
//            roomRef.setData(roomWithOffer) { (err) in
//                print("!!!!!!!!!!!")
//                if let err = err {
//                    print("Error send offer sdp: \(err)")
//                }
//                else {
//                    print("New room created with SDP offer. Room ID: \(roomRef.documentID)")
//                    self.roomId = roomRef.documentID
//                }
//            }
        })
    }
    
    func createAnswer() {
        let roomRef = db.collection("rooms").document()
        
        self.peerConnection!.answer(for: RTCMediaConstraints(mandatoryConstraints: self.mediaConstrains, optionalConstraints: nil),
                                       completionHandler: { (sdp, error) in
            guard let sdp = sdp else {
                return
            }
            self.peerConnection!.setLocalDescription(sdp)
            
            let roomWithAnswer = ["answer": ["type": sdp.type, "sdp": sdp.sdp]]
            roomRef.updateData(roomWithAnswer) { (err) in
                if let err = err {
                    print("Error send answer sdp: \(err)")
                }
                else {
                    print("Joined room with SDP answer. Room ID: \(roomRef.documentID)")
                }
            }
        })
    }
    
}


// MARK: - Peer Connection
extension WebRTCClient: RTCPeerConnectionDelegate {
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange stateChanged: RTCSignalingState) {
        print("peerConnection didChange signalingState: \(stateChanged)")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didAdd stream: RTCMediaStream) {
        print("peerConnection didAdd stream")
        DispatchQueue.main.async(execute: { () -> Void in
                    // mainスレッドで実行
                    if (stream.videoTracks.count > 0) {
                        // ビデオのトラックを取り出して
                        self.remoteVideoTrack = stream.videoTracks[0]
                    }
                })
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didRemove stream: RTCMediaStream) {
        print("peerConnection didRemove stream")
    }
    
    func peerConnectionShouldNegotiate(_ peerConnection: RTCPeerConnection) {
        print("peerConnection shoudNegotiate")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceConnectionState) {
        print("peerConnection didChange iceConnectionState: \(newState)")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceGatheringState) {
        print("peerConnection didChange iceGatheringState: \(newState)")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didGenerate candidate: RTCIceCandidate) {
        print("peerConnection didGenerate candidate")
        
        // candidate를 db로 보냄
        self.delegate?.webRTCClient(self, didDiscoverLocalCandidate: candidate)
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didRemove candidates: [RTCIceCandidate]) {
        print("peerConnection didRemove candidates")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didOpen dataChannel: RTCDataChannel) {
        print("peerConnection didOpen dataChannel")
    }
    
}
