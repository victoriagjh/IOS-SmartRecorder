//
//  choiceSpeecherViewController.swift
//  Recorder
//
//  Created by 권주희 on 18/05/2019.
//  Copyright © 2019 권주희. All rights reserved.
//

import UIKit
struct data {
    var num_speaker : Int
    var text : String
    var file_name : String
}
class choiceSpeecherViewController: UIViewController,UIGestureRecognizerDelegate,UITableViewDelegate,UITableViewDataSource {
    var recordFileData = data(num_speaker: 0,text: "",file_name:"")
    
    @IBOutlet weak var speecherView: UITableView!
    
    override func viewDidLoad() {
        // Do any additional setup after loading the view, typically from a nib.

        super.viewDidLoad()
        let swipeRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeAction(_:)))
        swipeRecognizer.direction = .right
        self.view.addGestureRecognizer(swipeRecognizer)
        speecherView.delegate = self
        speecherView.dataSource = self
    }

    @objc func swipeAction(_ sender:UISwipeGestureRecognizer) {
        if sender.direction == .right{
            dismiss(animated: true, completion: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "note"{
            let secondVC = segue.destination as! noteViewController
            secondVC.recordFileData.num_speaker = recordFileData.num_speaker
            secondVC.recordFileData.text = recordFileData.text
            secondVC.recordFileData.file_name = recordFileData.file_name
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recordFileData.num_speaker
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "speecherCell",for: indexPath) as! speecherTableViewCell
        var title = "speecher  "
        title+=String(indexPath.row+1)
        
        cell.speecherButton.setTitle(title, for: .normal)
        return cell
    }
}
class speecherTableViewCell : UITableViewCell {
    @IBOutlet weak var speecherButton: UIButton!
}
