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

class MeetingRoom: Codable {
    var caller: Avatar?
    var callee: Avatar?
    var isRoomOpened: Bool?
//    var roomRef: DocumentReference?
    
    init() {
        self.caller = nil
        self.callee = nil
        self.isRoomOpened = false
    }
    
    func createRoom(webRTCClient: WebRTCClient) -> DocumentReference {
        print("create room")
//        self.roomRef = db.collection("rooms").document()
        var roomRef = db.collection("rooms").document()
        
        webRTCClient.createPeerConnection()
        
        let callerCandidatesCollection = roomRef.collection("callerCandidates")
        
        webRTCClient.createOffer(roomRef: roomRef){ _ in
            print("create offer success")
        }
        
        self.isRoomOpened = true
        
//        return self.roomRef!
        return roomRef
    }
    
    func joinRoom(webRTCClient: WebRTCClient){
        if (self.isRoomOpened!) {
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
