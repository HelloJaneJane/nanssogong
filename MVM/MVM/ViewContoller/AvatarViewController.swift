//
//  AvatarViewController.swift
//  MVM
//
//  Created by 이제인 on 2021/11/04.
//

import UIKit

let avatarTopWidth = 193.13
let avatarTopHeight = 108.47
let avatarBottomWidth = 145.89
let avatarBottomHeight = 80.13

class AvatarViewContoller: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var avatarView: UIView!
    
    var nicknameView: UIView!
    var nicknameTextField: UITextField!
    
    var avatarPreviewView: UIView!
    var avatarFaceView: UIImageView!
    var avatarTopView: UIImageView!
    var avatarBottomView: UIImageView!
    
    var avatarSettingTableView: UITableView!
    
    // default avatar setting
    var avatarFace: Int = 1
    var avatarTopColor: Int = 1
    var avatarBottomColor: Int = 2
    
    
//    override func viewWillLayoutSubviews() {
    override func viewDidAppear(_ animated: Bool) {
        self.view.backgroundColor = UIColor.white
        
        let safeWidth = avatarView.safeAreaLayoutGuide.layoutFrame.width
        let safeHeight = avatarView.safeAreaLayoutGuide.layoutFrame.height
        let safeTop = avatarView.safeAreaInsets.top
        let safeBottom = safeTop + safeHeight
        
        let centerX = safeWidth/2
        
        // nickname (h=40)
        nicknameView = UIView(frame: CGRect(x: 0, y: safeTop, width: safeWidth, height: 40))
        
        nicknameTextField = UITextField(frame: CGRect(x: centerX-150, y: 5, width: 300, height: 35))
        nicknameTextField.delegate = self
        nicknameTextField.placeholder = "닉네임을 8자 이내로 입력하세요."
        nicknameTextField.backgroundColor = UIColor.secondarySystemFill
        nicknameTextField.keyboardType = .alphabet
        nicknameTextField.clearButtonMode = .whileEditing
        nicknameTextField.borderStyle = .roundedRect
        
        self.view.addSubview(nicknameView)
        nicknameView.addSubview(nicknameTextField)
        
        
        // preview (h=total-340)
        avatarPreviewView = UIView(frame: CGRect(x: 0, y: safeTop+40, width: safeWidth, height: safeHeight-340))
        
        let previewCenterY = avatarPreviewView.frame.size.height/2
        
        avatarFaceView = UIImageView(frame: CGRect(x: centerX - 50, y: previewCenterY - avatarTopHeight/2 - 80, width: 100, height: 100))
        avatarTopView = UIImageView(frame: CGRect(x: centerX - 95, y: previewCenterY - 50, width: avatarTopWidth, height: avatarTopHeight))
        avatarBottomView = UIImageView(frame: CGRect(x: centerX - 60, y: previewCenterY + 40, width: avatarBottomWidth, height: avatarBottomHeight))
        
        avatarFaceView.image = UIImage(named: "face_1.png")
        avatarTopView.image = UIImage(named: "top_1.png")
        avatarBottomView.image = UIImage(named: "bottom_2.png")
        
        self.view.addSubview(avatarPreviewView)
        avatarPreviewView.addSubview(avatarBottomView)
        avatarPreviewView.addSubview(avatarTopView)
        avatarPreviewView.addSubview(avatarFaceView)


        // setting (h=300)
        avatarSettingTableView = UITableView(frame: CGRect(x: 0, y: safeBottom - 300, width: safeWidth, height: 300))
        avatarSettingTableView.dataSource = self
        avatarSettingTableView.delegate = self
        avatarSettingTableView.register(AvatarSettingTableViewCell.self, forCellReuseIdentifier: "cell")
        
        avatarSettingTableView.backgroundColor = UIColor.clear
        
        self.view.addSubview(avatarSettingTableView)
        

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(avatarBackAction(_:)), name: UIScene.didEnterBackgroundNotification, object: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        self.codeTextField.resignFirstResponder()
        self.dismiss(animated: true, completion: nil)
        return true
    }
    
    // 8글자 제한
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            print(string)
            if let char = string.cString(using: String.Encoding.utf8) {
                let isBackSpace = strcmp(char, "\\b")
                if isBackSpace == -92 {
                    return true
                }
            }
            guard textField.text!.count < 8 else { return false }
            return true
        }
    

    
    
    func setFaceButton(button: UIButton, idx: Int) {
        button.setImage(UIImage(named: "face_"+String(idx)+".png"), for: .normal)
        button.tag = idx
        button.addTarget(self, action: #selector(self.faceButtonAction(_:)), for: .touchUpInside)
    }
    
    func setTopColorButton(button: UIButton, idx: Int) {
        let colors = [UIColor.red, UIColor.yellow, UIColor.green, UIColor.blue, UIColor.purple]
        button.backgroundColor = colors[idx-1]
        button.tag = idx
        button.addTarget(self, action: #selector(self.topColorButtonAction(_:)), for: .touchUpInside)
    }
    
    func setBottomColorButton(button: UIButton, idx: Int) {
        let colors = [UIColor.red, UIColor.yellow, UIColor.green, UIColor.blue, UIColor.purple]
        button.backgroundColor = colors[idx-1]
        button.tag = idx
        button.addTarget(self, action: #selector(self.bottomColorButtonAction(_:)), for: .touchUpInside)
    }
    
    
    @objc func faceButtonAction(_ sender: UIButton) {
        self.avatarFace = sender.tag
        avatarFaceView.image = UIImage(named: "face_"+String(sender.tag)+".png")
        avatarFaceView.setNeedsDisplay()
    }
    
    @objc func topColorButtonAction(_ sender: UIButton) {
        self.avatarTopColor = sender.tag
        avatarTopView.image = UIImage(named: "top_"+String(sender.tag)+".png")
        avatarTopView.setNeedsDisplay()
    }
    
    @objc func bottomColorButtonAction(_ sender: UIButton) {
        self.avatarBottomColor = sender.tag
        avatarBottomView.image = UIImage(named: "bottom_"+String(sender.tag)+".png")
        avatarBottomView.setNeedsDisplay()
    }
    
    @IBAction func avatarDone(_ sender: Any) {
        print("avatar done: " + nicknameTextField.text! as String)
//        self.performSegue(withIdentifier: "AvatarDoneSegue", sender: self)
        
        // nickname text 비어있으면 alert 띄우기
        if nicknameTextField.text! as String == "" {
            let alert = UIAlertController(title: "닉네임을 입력하세요.", message: "아바타를 생성할 수 없습니다.", preferredStyle: UIAlertController.Style.alert)
            let okAction = UIAlertAction(title: "OK", style: .default)
            alert.addAction(okAction)
            present(alert, animated: false, completion: nil)
        }

        else {

            // db에서 village 받아와서 avatar position 정하기
            myVillage?.updateFromFire(completion: { [self] in
                let newPos = myVillage?.getNewStartPosition()
                print(newPos)
                if newPos! == (-1, -1) {
                    print("village get new start position fail")
                    return
                }

                // 아바타 생성
                myAvatar = Avatar.init(nickname: nicknameTextField.text! as String, face: avatarFace, topColor: avatarTopColor, bottomColor: avatarBottomColor, position: newPos!)

                // 빌리지에 아바타 넣기
                myVillage?.villageMap[newPos!.0][newPos!.1] = myAvatar

                // db로 보내기
                myVillage?.sendToFire(completion: {
                    // village map 화면으로 옮기기
                    self.performSegue(withIdentifier: "AvatarDoneSegue", sender: self)
                })
            })
        }
    }
    
    @IBAction func avatarBackAction(_ sender: Any) {
        myVillage?.avatarNum! -= 1
        myVillage?.sendToFire(completion: {
            myVillage = nil
            self.navigationController?.popToRootViewController(animated: true)
        })
    }
    
    
}


// setting table view delegate
extension AvatarViewContoller: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "얼굴"
        case 1:
            return "상의"
        case 2:
            return "하의"
        default:
            return ""
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: AvatarSettingTableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! AvatarSettingTableViewCell
        cell.selectionStyle = .none
        
        let buttons = [cell.button1, cell.button2, cell.button3, cell.button4, cell.button5]
        
        if indexPath.section == 0 {
            for i in 1...buttons.count{
                setFaceButton(button: buttons[i-1], idx: i)
            }
        }
        else if indexPath.section == 1 {
            for i in 1...buttons.count{
                setTopColorButton(button: buttons[i-1], idx: i)
            }
        }
        else if indexPath.section == 2 {
            for i in 1...buttons.count{
                setBottomColorButton(button: buttons[i-1], idx: i)
            }
        }
        
        return cell
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
            cell.backgroundColor = UIColor.clear
    }
}
