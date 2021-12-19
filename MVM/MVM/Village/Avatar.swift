//
//  Avatar.swift
//  MVM
//
//  Created by 이제인 on 2021/11/25.
//

import Foundation


class Avatar: Codable {
    var avatarId: Int?
    var nickname: String?
    var face: Int?
    var topColor: Int?
    var bottomColor: Int?
    var position: [Int?]
    var isMeeting: Avatar?
    
    init(nickname: String, face: Int, topColor: Int, bottomColor: Int, position: (Int,Int)){
        self.avatarId = nil
        self.nickname = nickname
        self.face = face
        self.topColor = topColor
        self.bottomColor = bottomColor
        self.position = [position.0, position.1]
        self.isMeeting = nil
    }
    
    
    // direction: 0-up, 1-right, 2-down, 3-left
    func requestMove(direction: Int){
        // 호출되는 시기: ui에서 조이스틱이 버튼을 누르면 avatar.requestMove(0,1,2,3)를 호출한다
        // 하는 일: village 한테 나 옮겨달라고 village.moveAvatar(position: tuple, direction: int)
        print("requestMove(direction=\(direction))")
    }
    
}

var myAvatar: Avatar?
