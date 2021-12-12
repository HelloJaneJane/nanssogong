//
//  MeetingRoom.swift
//  MVM
//
//  Created by 이제인 on 2021/11/25.
//

import Foundation

import WebRTC
import FirebaseFirestore

let db = Firestore.firestore()

class MeetingRoom {
    var caller: Avatar?
    var callee: Avatar?
    var isRoomOpened: Bool
    
    init() {
        self.caller = nil
        self.callee = nil
        self.isRoomOpened = false
    }
    
    func createRoom(webRTCClient: WebRTCClient){
        print("create room")
        let roomRef = db.collection("rooms").document()
        
        webRTCClient.createPeerConnection()
        webRTCClient.createOffer(roomRef: roomRef){ _ in
            print("create offer success")
        }
                  
        print("여기까진돼?")
        
        // listen remote sdp
        roomRef.addSnapshotListener { snapshot, error in
            print("remote sdp snapshot")
            guard let document = snapshot else {
                print("Error fetching document: \(error!)")
                return
            }
            guard let data = document.data() else {
                print("Document data was empty.")
                return
            }
            if (webRTCClient.peerConnection?.remoteDescription != nil && data["answer"] != nil) {
                do {
                    let answerJSON = try JSONSerialization.data(withJSONObject: data["answer"], options: .fragmentsAllowed)
                    let answerSDP = try JSONDecoder().decode(SessionDescription.self, from: answerJSON)
                    print("Got remote description: \(answerSDP)")
                    webRTCClient.peerConnection!.setRemoteDescription(answerSDP.rtcSessionDescription,
                                                                      completionHandler: {(error) in
                        print("Warning: Could not set remote description: \(error)")}
                    )
                }
                catch {
                    print("Warning: Could not decode sdp data: \(error)")
                    return
                }
            }
        }
        
        // listen remote candidate
        roomRef.collection("calleeCandidates").addSnapshotListener { snapshot, error in
            print("callee candidate snapshot")
            guard let documents = snapshot?.documents else {
                print("Error fetching document: \(error!)")
                return
            }
            
            snapshot!.documentChanges.forEach { diff in
                if (diff.type == .added) {
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: documents.first!.data(), options: .prettyPrinted)
                        let iceCandidate = try JSONDecoder().decode(IceCandidate.self, from: jsonData)
                        print("Got new remote ICE candidate: \(iceCandidate)")
                        webRTCClient.peerConnection!.add(iceCandidate.rtcIceCandidate)
                    }
                    catch {
                        print("Warning: Could not decode candidate data: \(error)")
                        return
                    }
                }
            }
        }
        
//        self.roomId = webRTCClient.roomId
        self.isRoomOpened = true
    }
    
    func joinRoom(webRTCClient: WebRTCClient){
        if (self.isRoomOpened) {
            let roomId = webRTCClient.roomId
            let roomRef = db.collection("rooms").document(roomId!)
            roomRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    
                    webRTCClient.createPeerConnection()
                    guard let data = document.data() else {
                        print("Document data was empty.")
                        return
                    }
                    
                    let offer = data["offer"] as! [String : Any]
                    webRTCClient.peerConnection?.setRemoteDescription(RTCSessionDescription(type: offer["type"] as! RTCSdpType, sdp: offer["sdp"] as! String))
                    
                    webRTCClient.createAnswer()
                    
                    
                }
                else {
                    print("Document does not exist")
                }
            }
            
            // listen remote candidate
            roomRef.collection("callerCandidates").addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents else {
                    print("Error fetching document: \(error!)")
                    return
                }
                
                snapshot!.documentChanges.forEach { diff in
                    if (diff.type == .added) {
                        do {
                            let jsonData = try JSONSerialization.data(withJSONObject: documents.first!.data(), options: .prettyPrinted)
                            let iceCandidate = try JSONDecoder().decode(IceCandidate.self, from: jsonData)
                            print("Got new remote ICE candidate: \(iceCandidate)")
                            webRTCClient.peerConnection!.add(iceCandidate.rtcIceCandidate)
                        }
                        catch {
                            print("Warning: Could not decode candidate data: \(error)")
                            return
                        }
                    }
                }
            }
        }
    }
    
    func hangUp(){
        
    }
}
