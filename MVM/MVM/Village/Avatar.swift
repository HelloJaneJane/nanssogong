//
//  Avatar.swift
//  MVM
//
//  Created by 이제인 on 2021/11/25.
//

import Foundation


class Avatar {
//    var avatarId: Int
    var nickname: String
    var face: Int
    var topColor: Int
    var bottomColor: Int
//    var position: (Int, Int)
    var isMeeting: Bool
    
    init(nickname: String, face: Int, topColor: Int, bottomColor: Int){
        self.nickname = nickname
        self.face = face
        self.topColor = topColor
        self.bottomColor = bottomColor
        self.isMeeting = false
    }
    
    
    func requestMove(direction: Int){
        // 호출되는 시기: ui에서 조이스틱이 버튼을 누르면 avatar.requestMove(0,1,2,3)를 호출한다
        // 하는 일: village 한테 나 옮겨달라고 village.moveAvatar(position: tuple, direction: int)
    }
    
}
