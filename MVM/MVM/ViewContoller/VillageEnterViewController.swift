//
//  VillageEnterViewController.swift
//  MVM
//
//  Created by 이제인 on 2021/11/02.
//

import UIKit

class VillageEnterViewController: UIViewController{

    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var villageEnterButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.white
        logoImageView.image = UIImage(named:"logo.png")
        villageEnterButton.backgroundColor = UIColor.systemGreen
    }
    


    @IBAction func villageEnterButtonTouch(_ sender: Any) {
        
    }
    
}

