import UIKit
import AVFoundation
class ViewController: UIViewController, AVAudioPlayerDelegate, AVAudioRecorderDelegate,UITableViewDelegate,UITableViewDataSource {
    var audioPlayer: AVAudioPlayer?
    var audioRecorder: AVAudioRecorder?

    var recordFiles:[String] = [""]
    
    @IBOutlet weak var mainLabel: UILabel!
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
        let soundFileURL = NSURL(fileURLWithPath: soundFilePath)
        
        recordFiles = getRecordFileList() as! [String]

        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
        } catch {
            print("AudioSession Error")
        }
        do{
            try audioRecorder = AVAudioRecorder(url: soundFileURL as URL, settings: recordSettings )
            audioRecorder?.prepareToRecord()

        } catch {
            print("AudioRecorder Error")
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func recordButton(_ sender: Any) {
        if audioRecorder?.isRecording == false {
            let soundFileURL = NSURL(fileURLWithPath: makeSoundFileURL())
            do{
                try audioRecorder = AVAudioRecorder(url: soundFileURL as URL, settings: recordSettings )
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
        formatter.dateFormat = "yyyy_MM_dd hh:mm:ss"
        formatter.timeZone = NSTimeZone(name:"UTC") as TimeZone?
        let dateString = formatter.string(from: date)
        
        let soundFilePath = dirPaths[0] + "/"+dateString+".wav"
        return soundFilePath
    }
    
    func getRecordFileList() -> Array<Any> {
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
            recordFiles = getRecordFileList() as! [String]
            RecordFileView.reloadData()
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "recordCell",for: indexPath)
        let fileNames = recordFiles
        let fileName = fileNames[indexPath.row]
        cell.textLabel!.text = fileName //!는 optional이기 때문에 넣어주는 값임
        if let capacity:String = fileName{
            cell.detailTextLabel?.text = "\(capacity)"
        }
        return cell
    }
    
}

