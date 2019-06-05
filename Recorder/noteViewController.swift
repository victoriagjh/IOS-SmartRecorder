//
//  noteViewController.swift
//  Recorder
//
//  Created by 권주희 on 05/06/2019.
//  Copyright © 2019 권주희. All rights reserved.
//
import UIKit
import Foundation

struct datas {
    var num_speaker : Int
    var text : String
    var file_name : String
}

class noteViewController: UIViewController,UIGestureRecognizerDelegate {
    var recordFileData = datas(num_speaker: 0,text: "",file_name:"")

    @IBOutlet weak var fileName: UILabel!
    @IBOutlet weak var content: UITextView!
    @IBOutlet weak var topic: UILabel!
    @IBOutlet weak var keyword: UILabel!
    
    override func viewDidLoad() {
        // Do any additional setup after loading the view, typically from a nib.
        super.viewDidLoad()
        let swipeRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeAction(_:)))
        swipeRecognizer.direction = .right
        self.view.addGestureRecognizer(swipeRecognizer)
        
        self.fileName.text=recordFileData.file_name

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
