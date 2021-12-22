//
//  Village.swift
//  MVM
//
//  Created by 이제인 on 2021/11/25.
//

import Foundation

class FireVillage: Codable {
    var avatarNum: Int?
    var map0: [Avatar?]
    var map1: [Avatar?]
    var map2: [Avatar?]
    var map3: [Avatar?]
    var map4: [Avatar?]
    var meetingRooms: [MeetingRoom?]
    var meetingRoomPositions: [Int]
    
    init(village: Village) {
        self.avatarNum = village.avatarNum
        self.map0 = village.villageMap[0]
        self.map1 = village.villageMap[1]
        self.map2 = village.villageMap[2]
        self.map3 = village.villageMap[3]
        self.map4 = village.villageMap[4]
        self.meetingRooms = village.meetingRooms
        self.meetingRoomPositions = []
        for pos in village.meetingRoomPositions {
            self.meetingRoomPositions.append(pos.0.0)
            self.meetingRoomPositions.append(pos.0.1)
            self.meetingRoomPositions.append(pos.1.0)
            self.meetingRoomPositions.append(pos.1.1)
        }
    }
    
}

class Village {
    var villageId: String?
    var avatarNum: Int?
    var villageMap: [[Avatar?]]
    var meetingRooms: [MeetingRoom?]
    var meetingRoomPositions: [((Int,Int),(Int,Int))]
    
    init(villageId: String, meetingRoomPositions: [((Int,Int),(Int,Int))]) {
        self.villageId = villageId
        self.avatarNum = 0
        self.villageMap = [[Avatar?]](repeating: Array(repeating: nil, count: 5), count: 5)
        self.meetingRooms = [MeetingRoom?](repeating: MeetingRoom.init(), count: 4)
        self.meetingRoomPositions = meetingRoomPositions
    }
    
    init(villageId: String, fireVillage: FireVillage) {
        self.villageId = villageId
        self.avatarNum = fireVillage.avatarNum
        self.villageMap = [fireVillage.map0, fireVillage.map1, fireVillage.map2, fireVillage.map3, fireVillage.map4]
        self.meetingRooms = fireVillage.meetingRooms
        self.meetingRoomPositions = [((fireVillage.meetingRoomPositions[0],fireVillage.meetingRoomPositions[1]),(fireVillage.meetingRoomPositions[2],fireVillage.meetingRoomPositions[3])),((fireVillage.meetingRoomPositions[4],fireVillage.meetingRoomPositions[5]),(fireVillage.meetingRoomPositions[6],fireVillage.meetingRoomPositions[7])),((fireVillage.meetingRoomPositions[8],fireVillage.meetingRoomPositions[9]),(fireVillage.meetingRoomPositions[10],fireVillage.meetingRoomPositions[11])),((fireVillage.meetingRoomPositions[12],fireVillage.meetingRoomPositions[13]),(fireVillage.meetingRoomPositions[14],fireVillage.meetingRoomPositions[15]))]
    }
    
    // direction: 0-up, 1-right, 2-down, 3-left
    func moveAvatar(position: (Int,Int), direction: Int, webrtcClient: WebRTCClient, completion: @escaping () -> Void) {
        let d = [(-1,0),(0,1),(1,0),(0,-1)]
        let newR = position.0 + d[direction].0
        let newC = position.1 + d[direction].1
        print("move avatar (\(position)->\(newR),\(newC))")
        
        // 지도 안 영역
        if 0 <= newR && newR <= 4 && 0 <= newC && newC <= 4 {
            var avatar = self.villageMap[newR][newC]
            print("new position: \(avatar)")
            // 빈자리 아니면 옮길 수 있다
            if avatar == nil {
                self.villageMap[newR][newC] = self.villageMap[position.0][position.1]
                self.villageMap[newR][newC]?.position = [newR, newC]
                self.villageMap[position.0][position.1] = nil
                
                // 미팅 중이 아니면
                if self.villageMap[newR][newC]!.isMeeting == false {
                    self.checkNewMeeting(newPosition: (newR, newC), webrtcClient: webrtcClient, completion: {
                        
                    })
                }
                // 미팅 중이면
                else {
                    self.checkCloseMeeting(originPosition: position, newPosition: (newR, newC), webrtcClient: webrtcClient, completion: {
                        
                    })
                }
                
                self.sendToFire(completion: {
                    myAvatar = self.villageMap[newR][newC]
                    completion()
                })
            }
        }
    }
    
    func checkNewMeeting(newPosition: (Int, Int), webrtcClient: WebRTCClient, completion: @escaping () -> Void) {
        print("check new meeting")
        for idx in 0...3 {
            let pos0 = self.meetingRoomPositions[idx].0
            let pos1 = self.meetingRoomPositions[idx].1
            
            if (pos0.0 == newPosition.0 && pos0.1 == newPosition.1) || (pos1.0 == newPosition.0 && pos1.1 == newPosition.1) {
                // 이미 열린 회의실에 입장
                if self.meetingRooms[idx]!.isRoomOpened! {
                    self.meetingRooms[idx]?.joinRoom(webRTCClient: webrtcClient)
                    self.villageMap[newPosition.0][newPosition.1]?.isMeeting = true
                    self.meetingRooms[idx]?.callee = self.villageMap[newPosition.0][newPosition.1]
                    completion()
                }
                // 새로운 회의실 생성
                else {
                    var roomRef = self.meetingRooms[idx]?.createRoom(webRTCClient: webrtcClient)
                    webrtcClient.listenCallee(roomRef: roomRef!)
                    
                    self.villageMap[newPosition.0][newPosition.1]?.isMeeting = true
                    self.meetingRooms[idx]?.caller = self.villageMap[newPosition.0][newPosition.1]
                    
                    completion()
                    return
                }
            }
        }
    }
    
    func checkCloseMeeting(originPosition: (Int, Int), newPosition: (Int, Int), webrtcClient: WebRTCClient, completion: @escaping () -> Void) {
        print("check close meeting")
        
        for idx in 0...3 {
            let pos0 = self.meetingRoomPositions[idx].0
            let pos1 = self.meetingRoomPositions[idx].1
            print("pos=\(pos0),\(pos1) / origin=\(originPosition) / new=\(newPosition)")
            
            // origin은 회의실 자리, new는 안 회의실 자리
            if (pos0.0 == originPosition.0 && pos0.1 == originPosition.1 && (pos1.0 != newPosition.0 || pos1.1 != newPosition.1)) || (pos1.0 == originPosition.0 && pos1.1 == originPosition.1 && (pos0.0 != newPosition.0 || pos0.1 != newPosition.1)) {
                // 회의실 삭제
                print("hangup 해야함")
                self.meetingRooms[idx]?.hangUp(webRTCClient: webrtcClient)
                self.villageMap[pos0.0][pos0.1]?.isMeeting = false
                self.villageMap[pos1.0][pos1.1]?.isMeeting = false
                self.villageMap[newPosition.0][newPosition.1]?.isMeeting = false
                myAvatar?.isMeeting = false
            
                completion()
                return
            }
        }
        
    }
    
    func updateFromFire(completion: @escaping () -> Void) {
        let villageRef = db.collection("villages").document(self.villageId!)
        var village: Village?
        villageRef.getDocument { snapshot, error in
            guard let document = snapshot else {
                print("Error fetching document: \(error!)")
                return
            }
            guard let data = document.data() else {
                print("Document data was empty.")
                return
            }
            
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: data)
                let instance = try JSONDecoder().decode(FireVillage.self, from: jsonData)
                
                self.avatarNum = instance.avatarNum
                self.villageMap = [instance.map0, instance.map1, instance.map2, instance.map3, instance.map4]
                
                print("update village succeed")
                completion()
            }
            catch {
                print(error)
            }
        }
    }
    
    func sendToFire(completion: @escaping () -> Void) {
        let fireVillage = FireVillage.init(village: self)
        
        let villageRef = db.collection("villages").document(self.villageId!)
        
        do {
            let data = try JSONEncoder().encode(fireVillage)
            let dict = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String: Any]
            villageRef.updateData(dict) { (err) in
                if let err = err {
                    print("Error updating document (send to fire): \(err)")
                }
                else {
                    print("Document successfully updated (send to fire)")
                    completion()
                }
            }
        }
        catch {
            print("JSONSericalization caller candidate fail")
        }
    }
    
    func getNewStartPosition() -> (Int, Int){
        print("get new start position")
        for r in 0...4 {
            for c in 0...4 {
                // 그 자리에 아바타가 없고
                if self.villageMap[r][c] == nil {
                    // 회의실 자리가 아닐 때
                    if !self.meetingRoomPositions.contains(where: {$0.0 == (r,c)}) && !self.meetingRoomPositions.contains(where: {$0.1 == (r,c)}) {
                        return (r, c)
                    }
                }
            }
        }
        return (-1, -1)
    }
    
}


var myVillage: Village?




//func initVillage() {
//    let initialVillage1 = Village.init(villageId: "village1", meetingRoomPositions: [((0,3),(0,4)),((1,0),(1,1)),((3,3),(3,4)),((4,0),(4,1))])
//    let initialVillage2 = Village.init(villageId: "village2", meetingRoomPositions: [((0,2),(0,3)),((1,0),(2,0)),((2,3),(2,4)),((4,0),(4,1))])
//    let initialVillage3 = Village.init(villageId: "village3", meetingRoomPositions: [((0,0),(0,1)),((1,3),(1,4)),((3,3),(3,4)),((3,0),(4,0))])
//    let initialVillage4 = Village.init(villageId: "village4", meetingRoomPositions: [((0,3),(0,4)),((1,0),(2,0)),((2,3),(2,4)),((4,1),(4,2))])
//
//    let villagedata1 = FireVillage.init(village: initialVillage1)
//    let villagedata2 = FireVillage.init(village: initialVillage2)
//    let villagedata3 = FireVillage.init(village: initialVillage3)
//    let villagedata4 = FireVillage.init(village: initialVillage4)
//
//    do {
//        var data = try JSONEncoder().encode(villagedata1)
//        var dict = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String: Any]
//        var villageRef = db.collection("villages").document("village1")
//
//        villageRef.setData(dict) { (err) in
//            if let err = err {
//                print("Error send village: \(err)")
//            }
//            else {
//                print("send village")
//            }
//        }
//
//
//        data = try JSONEncoder().encode(villagedata2)
//        dict = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String: Any]
//        villageRef = db.collection("villages").document("village2")
//        villageRef.setData(dict) { (err) in
//            if let err = err {
//                print("Error send village: \(err)")
//            }
//            else {
//                print("send village")
//            }
//        }
//
//        data = try JSONEncoder().encode(villagedata3)
//        dict = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String: Any]
//        villageRef = db.collection("villages").document("village3")
//        villageRef.setData(dict) { (err) in
//            if let err = err {
//                print("Error send village: \(err)")
//            }
//            else {
//                print("send village")
//            }
//        }
//
//        data = try JSONEncoder().encode(villagedata4)
//        dict = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String: Any]
//        villageRef = db.collection("villages").document("village4")
//        villageRef.setData(dict) { (err) in
//            if let err = err {
//                print("Error send village: \(err)")
//            }
//            else {
//                print("send village")
//            }
//        }
//
//    }
//    catch {
//        print("JSONSericalization village fail")
//    }
//}
//
//func initTestVillage() {
//    let initialVillage1 = Village.init(villageId: "village1test", meetingRoomPositions: [((0,3),(0,4)),((1,0),(1,1)),((3,3),(3,4)),((4,0),(4,1))])
//    let initialVillage2 = Village.init(villageId: "village2test", meetingRoomPositions: [((0,2),(0,3)),((1,0),(2,0)),((2,3),(2,4)),((4,0),(4,1))])
//    let initialVillage3 = Village.init(villageId: "village3test", meetingRoomPositions: [((0,0),(0,1)),((1,3),(1,4)),((3,3),(3,4)),((3,0),(4,0))])
//    let initialVillage4 = Village.init(villageId: "village4test", meetingRoomPositions: [((0,3),(0,4)),((1,0),(2,0)),((2,3),(2,4)),((4,1),(4,2))])
//
//    let villagedata1 = FireVillage.init(village: initialVillage1)
//    let villagedata2 = FireVillage.init(village: initialVillage2)
//    let villagedata3 = FireVillage.init(village: initialVillage3)
//    let villagedata4 = FireVillage.init(village: initialVillage4)
//
//    do {
//        var data = try JSONEncoder().encode(villagedata1)
//        var dict = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String: Any]
//        var villageRef = db.collection("villages").document("village1test")
//
//        villageRef.setData(dict) { (err) in
//            if let err = err {
//                print("Error send village: \(err)")
//            }
//            else {
//                print("send village")
//            }
//        }
//
//
//        data = try JSONEncoder().encode(villagedata2)
//        dict = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String: Any]
//        villageRef = db.collection("villages").document("village2test")
//        villageRef.setData(dict) { (err) in
//            if let err = err {
//                print("Error send village: \(err)")
//            }
//            else {
//                print("send village")
//            }
//        }
//
//        data = try JSONEncoder().encode(villagedata3)
//        dict = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String: Any]
//        villageRef = db.collection("villages").document("village3test")
//        villageRef.setData(dict) { (err) in
//            if let err = err {
//                print("Error send village: \(err)")
//            }
//            else {
//                print("send village")
//            }
//        }
//
//        data = try JSONEncoder().encode(villagedata4)
//        dict = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String: Any]
//        villageRef = db.collection("villages").document("village4test")
//        villageRef.setData(dict) { (err) in
//            if let err = err {
//                print("Error send village: \(err)")
//            }
//            else {
//                print("send village")
//            }
//        }
//
//    }
//    catch {
//        print("JSONSericalization village fail")
//    }
//}
