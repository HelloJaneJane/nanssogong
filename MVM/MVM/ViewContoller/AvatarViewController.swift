//
//  AvatarViewController.swift
//  MVM
//
//  Created by 이제인 on 2021/11/04.
//

import UIKit

class AvatarViewContoller: UIViewController{
    
//}, UITableViewDelegate, UITableViewDataSource{
    @IBOutlet var avatarView: UIView!
    
    override func viewWillLayoutSubviews() {
        let safeWidth = avatarView.safeAreaLayoutGuide.layoutFrame.width
        let safeHeight = avatarView.safeAreaLayoutGuide.layoutFrame.height
        let safeTop = avatarView.safeAreaInsets.top
        let safeBottom = safeTop + safeHeight
        
        let avatarPreviewView = UIView(frame: CGRect(x: 0, y: safeTop, width:safeWidth, height: safeHeight - 300))
//        avatarPreviewView.backgroundColor = UIColor.red
        
        let avatarSettingView = UIView(frame: CGRect(x: 0, y: safeBottom - 300, width: safeWidth, height: 300))
        avatarSettingView.backgroundColor = UIColor.green
        
        self.view.addSubview(avatarPreviewView)
        self.view.addSubview(avatarSettingView)
        
        let centerX = safeWidth/2
        let previewCenterY = safeTop + avatarPreviewView.frame.size.height/2
        
        let avatarTopWidth = 193.13
        let avatarTopHeight = 108.47
        let avatarBottomWidth = 145.89
        let avatarBottomHeight = 80.13
        
        let avatarFaceView = UIImageView(frame: CGRect(x: centerX - 50, y: previewCenterY - avatarTopHeight/2 - 100, width: 100, height: 100))
        let avatarTopView = UIImageView(frame: CGRect(x: centerX - avatarTopWidth/2, y: previewCenterY - avatarTopHeight/2, width: avatarTopWidth, height: avatarTopHeight))
        let avatarBottomView = UIImageView(frame: CGRect(x: centerX - avatarBottomWidth/2, y: previewCenterY + avatarTopHeight/2, width: avatarBottomWidth, height: avatarBottomHeight))
        
        avatarFaceView.image = UIImage(named: "face_grinning.png")
        avatarTopView.image = UIImage(named: "top_red.png")
        avatarBottomView.image = UIImage(named: "bottom_yellow.png")
        
        self.view.addSubview(avatarFaceView)
        self.view.addSubview(avatarTopView)
        self.view.addSubview(avatarBottomView)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return 3
//    }
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        switch section {
//        case 0:
//            return "얼굴"
//        case 1:
//            return "상의"
//        case 2:
//            return "하의"
//        default:
//            return ""
//        }
//    }
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return 1
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
//        cell.textLabel?.text = "sample"
//        return cell
//    }
}
