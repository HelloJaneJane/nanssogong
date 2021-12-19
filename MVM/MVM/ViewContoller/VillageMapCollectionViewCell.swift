//
//  VillageMapCollectionViewCell.swift
//  MVM
//
//  Created by 이제인 on 2021/12/19.
//

import UIKit

class VillageMapCollectionViewCell: UICollectionViewCell {
    
    var contentFrame: CGRect?
    var backgroundImageView: UIImageView?
    
    var avatarNicknameView: UILabel?
    var avatarFaceView: UIImageView?
    var avatarTopView: UIImageView?
    var avatarBottomView: UIImageView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentFrame = self.contentView.frame
        
        self.setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setLayout() {
        backgroundImageView = UIImageView(frame: contentFrame!)
        self.contentView.addSubview(backgroundImageView!)
        
        let w = contentFrame!.width
        let p = 0.7*w/avatarTopWidth
        
        let centerX = w/2
        let centerY = 0.5+w*0.6
        
        avatarNicknameView = UILabel(frame: CGRect(x: 0, y: 1, width: w, height: w*0.2))
        avatarNicknameView!.font = UIFont.boldSystemFont(ofSize: 13)
        avatarNicknameView!.textAlignment = .center
        
        avatarFaceView = UIImageView(frame: CGRect(x: centerX-50*p, y: centerY - avatarTopHeight*p/2 - 80*p, width: 100*p, height: 100*p))
        avatarTopView = UIImageView(frame: CGRect(x: centerX - 95*p, y: centerY-50*p, width: avatarTopWidth*p, height: avatarTopHeight*p))
        avatarBottomView = UIImageView(frame: CGRect(x: centerX-60*p, y: centerY+40*p, width: avatarBottomWidth*p, height: avatarBottomHeight*p))
        
        self.contentView.addSubview(avatarBottomView!)
        self.contentView.addSubview(avatarTopView!)
        self.contentView.addSubview(avatarFaceView!)
        self.contentView.addSubview(avatarNicknameView!)
    }
}
