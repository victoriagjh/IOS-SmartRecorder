//
//  choiceSpeecherViewController.swift
//  Recorder
//
//  Created by 권주희 on 18/05/2019.
//  Copyright © 2019 권주희. All rights reserved.
//

import UIKit
class choiceSpeecherViewController: UIViewController,UIGestureRecognizerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let swipeRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeAction(_:)))
        swipeRecognizer.direction = .right
        self.view.addGestureRecognizer(swipeRecognizer)
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    @objc func swipeAction(_ sender:UISwipeGestureRecognizer) {
        if sender.direction == .right{
            dismiss(animated: true, completion: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
 
}
