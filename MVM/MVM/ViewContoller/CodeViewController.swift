//
//  ViewController.swift
//  MVM
//
//  Created by 이제인 on 2021/11/02.
//

import UIKit

class CodeViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var codeTextField: UITextField!
    @IBOutlet weak var villageEnterButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.white
        logoImageView.image = UIImage(named:"logo.png")
        codeTextField.becomeFirstResponder()
        codeTextField.keyboardType = .numberPad
        villageEnterButton.backgroundColor = UIColor.systemGreen
    }
    

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.codeTextField.resignFirstResponder()
        self.dismiss(animated: true, completion: nil)
        return true
    }

    @IBAction func villageEnterButtonTouch(_ sender: Any) {
        
    }
    
}

