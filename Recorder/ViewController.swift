import UIKit
import AVFoundation
import Alamofire

class recordCellTableViewCell:UITableViewCell {
    @IBOutlet weak var fileTimeLabel: UILabel!
    @IBOutlet weak var sendFileButton: UIButton!
    @IBOutlet weak var fileNameLabel: UILabel!
    var uploadRecordFile: (() -> Void)? = nil
    
    @IBAction func uploadFile(_ sender: Any) {
        uploadRecordFile?()
    }
}

class ViewController: UIViewController, AVAudioPlayerDelegate, AVAudioRecorderDelegate,UITableViewDelegate,UITableViewDataSource {
    var audioPlayer: AVAudioPlayer?
    var audioRecorder: AVAudioRecorder?
    var soundFileURL: NSURL?
    var recordFiles:[String] = [""]
    
    var file_name = String()
    var num_speaker = Int()
    var file_text = String()
    
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var RecordFileView: UITableView!
    
    var dirPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
    var recordSettings : [String: AnyObject] = [AVEncoderAudioQualityKey: AVAudioQuality.min.rawValue as AnyObject,AVEncoderBitRateKey: 16 as AnyObject,AVNumberOfChannelsKey: 2 as AnyObject, AVSampleRateKey : 44100.0 as AnyObject]

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        playButton.isEnabled = false
        stopButton.isEnabled = false
        
        _ = dirPaths[0] as String
        
        let soundFilePath = dirPaths[0]
        soundFileURL = NSURL(fileURLWithPath: soundFilePath)
        
        recordFiles = getRecordFileNameList() as! [String]

        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
        } catch {
            print("AudioSession Error")
        }
        do{
            try audioRecorder = AVAudioRecorder(url: soundFileURL! as URL, settings: recordSettings )
            audioRecorder?.prepareToRecord()

        } catch {
            print("AudioRecorder Error")
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "choiceSpeecher"{
            let secondVC = segue.destination as! choiceSpeecherViewController
            secondVC.recordFileData.num_speaker = self.num_speaker
            secondVC.recordFileData.text = self.file_text
            secondVC.recordFileData.file_name = self.file_name
        }
    }

    @IBAction func recordButton(_ sender: Any) {
        if audioRecorder?.isRecording == false {
            soundFileURL = NSURL(fileURLWithPath: makeSoundFileURL())
            do{
                try audioRecorder = AVAudioRecorder(url: soundFileURL! as URL, settings: recordSettings )
                audioRecorder?.prepareToRecord()
            } catch {
                print("AudioRecorder error")
            }
            recordButton.isEnabled = false
            playButton.isEnabled = false
            stopButton.isEnabled = true
            audioRecorder?.record()
        }
    }
    func makeSoundFileURL() -> String {
        let date:Date = Date()
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy_MM_dd HH:MM:ss"
        formatter.timeZone = NSTimeZone(name:"UTC") as TimeZone?
        let dateString = formatter.string(from: date)
        
        let soundFilePath = dirPaths[0] + "/"+dateString+".wav"
        return soundFilePath
    }
    
    func getRecordFileNameList() -> Array<Any> {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        do{
            let directoryContents = try FileManager.default.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil, options:[])
            print(directoryContents)
            
            let wavFiles = directoryContents.filter{$0.pathExtension == "wav"}
            print("wav File", wavFiles,"\n")
            let wavFileNames = wavFiles.map{ $0.deletingPathExtension().lastPathComponent }
            print("wavFile list", wavFileNames,"\n")
            return wavFileNames
            
        }catch{
            print(error)
        }
        return ["ERROR"]
    }

    @IBAction func stopButton(_ sender: Any) {
        stopButton.isEnabled = false
        playButton.isEnabled = true
        recordButton.isEnabled = true
        
        if audioRecorder?.isRecording == true {
            audioRecorder?.stop()
            recordFiles = getRecordFileNameList() as! [String]
            let range = NSMakeRange(0, self.RecordFileView.numberOfSections)
            let sections = NSIndexSet(indexesIn: range)
            self.RecordFileView.reloadSections(sections as IndexSet, with: .automatic)

        } else {
            print("Audio Recorder was not working")
        }
        
    }
    @IBAction func playButton(_ sender: Any) {
        if audioRecorder?.isRecording == false {
            stopButton.isEnabled = true
            recordButton.isEnabled = false
            do{
                try audioPlayer = AVAudioPlayer(contentsOf: (audioRecorder?.url)!)
                audioPlayer?.delegate = self
                audioPlayer?.play()
            } catch{
                print("AudioPlayer error ")
            }
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        recordButton.isEnabled = true
        stopButton.isEnabled = false
    }
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        print("Audio Play Decode Error")
    }
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        
    }
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        print("Audio")
    }
    
    //SETTING UP TABLE VIEW
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recordFiles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "recordCell",for: indexPath) as! recordCellTableViewCell
        let fileNames = recordFiles
        let fileName = fileNames[indexPath.row]
        cell.fileNameLabel!.text = fileName
        cell.fileTimeLabel!.text = "wav file"
        
        cell.uploadRecordFile={
            print("this row file name : ", fileName)
            
            let soundFilePath = self.dirPaths[0] + "/"+fileName+".wav"
            self.soundFileURL = NSURL(fileURLWithPath: soundFilePath)


            let audiodata = NSData (contentsOf: self.soundFileURL! as URL) as Data?
            
            let parameters: Parameters = [
                "title" : "Trying to upload" ]
            Alamofire.upload(multipartFormData: { MultipartFormData in
                MultipartFormData.append(audiodata!, withName: "file" , fileName: fileName+".wav" , mimeType: "/wav")
                for (key, value) in parameters {
                    MultipartFormData.append((value as AnyObject).data(using: String.Encoding.utf8.rawValue)!, withName: key)
                }
            }
                , to: "http://163.180.173.83:9099/file", encodingCompletion: {
                    EncodingResult in
                    switch EncodingResult{
                    case .success(let upload, _, _):
                        upload.responseJSON(completionHandler: { response in
                            let jsonDict = response.result.value as? NSDictionary
                            self.file_name = fileName
                            self.file_text = self.jsonToString(json: jsonDict?.object(forKey: "text") as AnyObject)
                            self.num_speaker = jsonDict?.object(forKey: "num_speaker") as! Int
                            self.performSegue(withIdentifier: "choiceSpeecher", sender: self)

                        })
                    case .failure(let encodingError):
                        print("ERROR RESPONSE: \(encodingError)")
                    }
            }
            )
        }

        return cell
    }
    func jsonToString(json: AnyObject) -> String{
        do {
            let data1 =  try JSONSerialization.data(withJSONObject: json, options: JSONSerialization.WritingOptions.prettyPrinted) // first of all convert json to the data
            let convertedString = String(data: data1, encoding: String.Encoding.utf8) // the data will be converted to the string
            return convertedString!
        } catch let myJSONError {
            print(myJSONError)
            return "FAIL json to string"
        }
        
    }
    
}

