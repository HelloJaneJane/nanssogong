//
//  VillageMapViewController.swift
//  MVM
//
//  Created by 이제인 on 2021/11/04.
//

import UIKit

class VillageMapViewContoller: UIViewController{
    
    @IBAction func villageExit(_ sender: Any) {
        let alert = UIAlertController(title: "빌리지를 나가시겠습니까?", message: "빌리지 입장 화면으로 이동합니다.", preferredStyle: UIAlertController.Style.alert)
        let yesAction = UIAlertAction(title: "Yes", style: .default) { (action) in
            // village enter view로 이동
            self.performSegue(withIdentifier: "VillageExitSegue", sender: self)
        }
        let noAction = UIAlertAction(title: "NO", style: .cancel)
        alert.addAction(yesAction)
        alert.addAction(noAction)
        present(alert, animated: false, completion: nil)
        
        
    }
    
}
