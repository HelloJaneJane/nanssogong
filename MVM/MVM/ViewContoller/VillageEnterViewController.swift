//
//  VillageEnterViewController.swift
//  MVM
//
//  Created by 이제인 on 2021/11/02.
//

import UIKit
import FirebaseFirestore

class VillageEnterViewController: UIViewController{

    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var villageEnterButton: UIButton!
    
    @IBOutlet weak var villagePickerTextField: UITextField!

    let villagePickerView = UIPickerView()
    var selectedVillage = ""
    
    var pickerData: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        initTestVillage()
        
        self.view.backgroundColor = UIColor.white
        logoImageView.image = UIImage(named:"logo.png")
        villageEnterButton.backgroundColor = UIColor.systemGreen
        
        // db에서 빌리지 데이터 받아오기 (getVillageList)
        db.collection("villages").getDocuments { snapshot, err in
            if let err = err {
                print("Error getting documents: \(err)")
            }
            else {
                for document in snapshot!.documents {
                    self.pickerData.append(document.documentID)
                }
            }
        }
        
        // 텍스트필드 누르면 피커 나와서 빌리지 선택
        villagePickerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 220)
        villagePickerView.delegate = self
        villagePickerView.dataSource = self
        
        let pickerToolbar : UIToolbar = UIToolbar()
        pickerToolbar.barStyle = .default
        pickerToolbar.isTranslucent = true
        pickerToolbar.backgroundColor = .lightGray
        pickerToolbar.sizeToFit()
        
        let btnDone = UIBarButtonItem(title: "확인", style: .done, target: self, action: #selector(onPickDone))
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let btnCancel = UIBarButtonItem(title: "취소", style: .done, target: self, action: #selector(onPickCancel))
        pickerToolbar.setItems([btnCancel , space , btnDone], animated: true)
        pickerToolbar.isUserInteractionEnabled = true
        
        villagePickerTextField.inputView = villagePickerView
        villagePickerTextField.inputAccessoryView = pickerToolbar

    }
    
    @objc func onPickDone() {
        villagePickerTextField.text = selectedVillage
        villagePickerTextField.resignFirstResponder()
        selectedVillage = ""
    }
   
    @objc func onPickCancel() {
        villagePickerTextField.resignFirstResponder()
        selectedVillage = ""
    }

    @IBAction func villageEnterButtonTouch(_ sender: Any) {
//        self.performSegue(withIdentifier: "VillageEnterSegue", sender: self)


        let villageId = villagePickerTextField.text! as String
        if villageId == "" {
            let alert = UIAlertController(title: "빌리지를 선택하세요.", message: "빌리지에 입장할 수 없습니다.", preferredStyle: UIAlertController.Style.alert)
            let okAction = UIAlertAction(title: "OK", style: .default)
            alert.addAction(okAction)
            self.present(alert, animated: false, completion: nil)
        }
        // 빌리지 선택 후 입장 시도
        else {
            // get village
            let villageRef = db.collection("villages").document(villageId)
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
                    var jsonData = try JSONSerialization.data(withJSONObject: data)
                    var instance = try JSONDecoder().decode(FireVillage.self, from: jsonData)

                    // 입장 가능
                    if instance.avatarNum!<8 {
                        instance.avatarNum! += 1
                        villageRef.updateData(["avatarNum": instance.avatarNum]) { err in
                            if let err = err {
                                print("Error updating document (village enter): \(err)")
                            }
                            else {
                                print("Document successfully updated (village enter)")

                                myVillage = Village.init(villageId: villageId, fireVillage: instance)
                                print(myVillage?.villageId)

                                // avatar 화면으로 옮기기
                                self.performSegue(withIdentifier: "VillageEnterSegue", sender: self)
                            }
                        }
                    }
                    // 입장 불가능
                    else {
                        let alert = UIAlertController(title: "빌리지가 꽉 찼습니다.", message: "빌리지에 입장할 수 없습니다.", preferredStyle: UIAlertController.Style.alert)
                        let okAction = UIAlertAction(title: "OK", style: .default)
                        alert.addAction(okAction)
                        self.present(alert, animated: false, completion: nil)
                    }
                }
                catch {
                    print(error)
                }
            }
        }

    }
    
}

extension VillageEnterViewController: UIPickerViewDelegate, UIPickerViewDataSource {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        pickerData.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedVillage = pickerData[row]
    }
}
