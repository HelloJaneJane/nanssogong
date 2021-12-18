//
//  Village.swift
//  MVM
//
//  Created by 이제인 on 2021/11/25.
//

import Foundation

class fireVillage: Codable {
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
    
    init(villageId: String, fireVillage: fireVillage) {
        self.villageId = villageId
        self.avatarNum = fireVillage.avatarNum
        self.villageMap = [fireVillage.map0, fireVillage.map1, fireVillage.map2, fireVillage.map3, fireVillage.map4]
        self.meetingRooms = fireVillage.meetingRooms
        self.meetingRoomPositions = [((fireVillage.meetingRoomPositions[0],fireVillage.meetingRoomPositions[1]),(fireVillage.meetingRoomPositions[2],fireVillage.meetingRoomPositions[3])),((fireVillage.meetingRoomPositions[4],fireVillage.meetingRoomPositions[5]),(fireVillage.meetingRoomPositions[6],fireVillage.meetingRoomPositions[7])),((fireVillage.meetingRoomPositions[8],fireVillage.meetingRoomPositions[9]),(fireVillage.meetingRoomPositions[10],fireVillage.meetingRoomPositions[11])),((fireVillage.meetingRoomPositions[12],fireVillage.meetingRoomPositions[13]),(fireVillage.meetingRoomPositions[14],fireVillage.meetingRoomPositions[15]))]
    }
    
    func moveAvatar(position: (Int,Int), direction: Int) {
        
    }
    
    func checkNewMeeting(newPosition: (Int, Int)) {
        
    }
    
    func checkCloseMeeting(originPosition: (Int,Int), newPosition: (Int,Int)) {
        
    }
    
}


var myVillage: Village?



//func initVillage() {
//    let initialVillage1 = Village.init(villageId: "village1", meetingRoomPositions: [((0,3),(0,4)),((1,0),(1,1)),((3,3),(3,4)),((4,0),(4,1))])
//    let initialVillage2 = Village.init(villageId: "village2", meetingRoomPositions: [((0,2),(0,3)),((1,0),(2,0)),((2,3),(2,4)),((4,0),(4,1))])
//    let initialVillage3 = Village.init(villageId: "village3", meetingRoomPositions: [((0,0),(0,1)),((1,3),(1,4)),((3,3),(3,4)),((3,0),(4,0))])
//    let initialVillage4 = Village.init(villageId: "village4", meetingRoomPositions: [((0,3),(0,4)),((1,0),(2,0)),((2,3),(2,4)),((4,1),(4,2))])
//
//    let villagedata1 = fireVillage.init(village: initialVillage1)
//    let villagedata2 = fireVillage.init(village: initialVillage2)
//    let villagedata3 = fireVillage.init(village: initialVillage3)
//    let villagedata4 = fireVillage.init(village: initialVillage4)
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
