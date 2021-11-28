//
//  AvatarSettingTableViewCell.swift
//  MVM
//
//  Created by 이제인 on 2021/11/28.
//

import UIKit

class AvatarSettingTableViewCell: UITableViewCell {
    
    lazy var button1: UIButton = UIButton()
    lazy var button2: UIButton = UIButton()
    lazy var button3: UIButton = UIButton()
    lazy var button4: UIButton = UIButton()
    lazy var button5: UIButton = UIButton()
    
    func setButtonLayout(button: UIButton!, idx: Int) {
        
        self.contentView.addSubview(button)
        
        // autolayout
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 40).isActive = true
        button.widthAnchor.constraint(equalToConstant: 40).isActive = true
        button.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        switch idx {
        case 1, 2:
            button.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: CGFloat(-70*(3-idx))).isActive = true
        case 4, 5:
            button.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: CGFloat(70*(idx-3))).isActive = true
        default: // case 3
            button.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        }
        
        // circle
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 20
    }
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.setButtonLayout(button: button1, idx: 1)
        self.setButtonLayout(button: button2, idx: 2)
        self.setButtonLayout(button: button3, idx: 3)
        self.setButtonLayout(button: button4, idx: 4)
        self.setButtonLayout(button: button5, idx: 5)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
