import UIKit
import AVFoundation
class ViewController: UIViewController, AVAudioPlayerDelegate, AVAudioRecorderDelegate{
    var audioPlayer: AVAudioPlayer?
    var audioRecorder: AVAudioRecorder?

    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        playButton.isEnabled = false
        stopButton.isEnabled = false
        
        let dirPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let docsDir = dirPaths[0] as String
        let soundFilePath = dirPaths[0] + "/test.wav"
        let soundFileURL = NSURL(fileURLWithPath: soundFilePath)
        print(soundFileURL)
        print(soundFilePath)
        
        let recordSettings : [String: AnyObject] = [AVEncoderAudioQualityKey: AVAudioQuality.min.rawValue as AnyObject,AVEncoderBitRateKey: 16 as AnyObject,AVNumberOfChannelsKey: 2 as AnyObject, AVSampleRateKey : 44100.0 as AnyObject]

        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
        } catch {
            print("AudioSession Error")
        }
        do{
            try audioRecorder = AVAudioRecorder(url: soundFileURL as URL, settings: recordSettings as! [String: AnyObject])
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
            recordButton.isEnabled = false
            playButton.isEnabled = false
            stopButton.isEnabled = true
            audioRecorder?.record()
            
        }
        
    }
    
    @IBAction func stopButton(_ sender: Any) {
        stopButton.isEnabled = false
        playButton.isEnabled = true
        recordButton.isEnabled = true
        
        if audioRecorder?.isRecording == true {
            audioRecorder?.stop()
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
}

